require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/slice'

module ActionDispatch
  module Http
    module URL
      IP_HOST_REGEXP  = /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
      HOST_REGEXP     = /(^[^:]+:\/\/)?([^:]+)(?::(\d+$))?/
      PROTOCOL_REGEXP = /^([^:]+)(:)?(\/\/)?$/

      mattr_accessor :tld_length
      self.tld_length = 1

      class << self
        def extract_domain(host, tld_length)
          extract_domain_from(host, tld_length) if named_host?(host)
        end

        def extract_subdomains(host, tld_length)
          if named_host?(host)
            extract_subdomains_from(host, tld_length)
          else
            []
          end
        end

        def extract_subdomain(host, tld_length)
          extract_subdomains(host, tld_length).join('.')
        end

        def url_for(options)
          unless options[:host] || options[:only_path]
            raise ArgumentError, 'Missing host to link to! Please provide the :host parameter, set default_url_options[:host], or set :only_path to true'
          end

          path  = options[:script_name].to_s.chomp("/")
          path << options[:path].to_s

          path = add_trailing_slash(path) if options[:trailing_slash]

          result = if options[:only_path]
                     path
                   else
                     build_host_url(options).concat path
                   end

          if options.key? :params
            params = options[:params].is_a?(Hash) ?
                                 options[:params] :
                                 { params: options[:params] }

            params.reject! { |_,v| v.to_param.nil? }
            result << "?#{params.to_query}" unless params.empty?
          end

          result << "##{Journey::Router::Utils.escape_fragment(options[:anchor].to_param.to_s)}" if options[:anchor]
          result
        end

        private

        def extract_domain_from(host, tld_length)
          host.split('.').last(1 + tld_length).join('.')
        end

        def extract_subdomains_from(host, tld_length)
          parts = host.split('.')
          parts[0..-(tld_length + 2)]
        end

        def add_trailing_slash(path)
          # includes querysting
          if path.include?('?')
            path.sub!(/\?/, '/\&')
          # does not have a .format
          elsif !path.include?(".")
            path.sub!(/[^\/]\z|\A\z/, '\&/')
          end

          path
        end

        def build_host_url(options)
          protocol = options[:protocol]
          host     = options[:host]
          port     = options[:port]
          if match = host.match(HOST_REGEXP)
            protocol           ||= match[1] unless protocol == false
            host                 = match[2]
            port                 = match[3] unless options.key? :port
          end

          protocol       = normalize_protocol protocol
          host           = normalize_host(host, options)

          result = protocol.dup

          if options[:user] && options[:password]
            result << "#{Rack::Utils.escape(options[:user])}:#{Rack::Utils.escape(options[:password])}@"
          end

          result << host
          normalize_port(port, protocol) { |normalized_port|
            result << ":#{normalized_port}"
          }

          result
        end

        def named_host?(host)
          IP_HOST_REGEXP !~ host
        end

        def normalize_protocol(protocol)
          case protocol
          when nil
            "http://"
          when false, "//"
            "//"
          when PROTOCOL_REGEXP
            "#{$1}://"
          else
            raise ArgumentError, "Invalid :protocol option: #{protocol.inspect}"
          end
        end

        def normalize_host(_host, options)
          return _host unless named_host?(_host)

          tld_length = options[:tld_length] || @@tld_length
          subdomain  = options.fetch :subdomain, true
          domain     = options[:domain]

          host = ""
          if subdomain == true
            return _host if domain.nil?

            host << extract_subdomains_from(_host, tld_length).join('.')
          elsif subdomain
            host << subdomain.to_param
          end
          host << "." unless host.empty?
          host << (domain || extract_domain_from(_host, tld_length))
          host
        end

        def normalize_port(port, protocol)
          return unless port

          case protocol
          when "//" then yield port
          when "https://"
            yield port unless port.to_i == 443
          else
            yield port unless port.to_i == 80
          end
        end
      end

      def initialize(env)
        super
        @protocol = nil
        @port     = nil
      end

      # Returns the complete URL used for this request.
      def url
        protocol + host_with_port + fullpath
      end

      # Returns 'https://' if this is an SSL request and 'http://' otherwise.
      def protocol
        @protocol ||= ssl? ? 'https://' : 'http://'
      end

      # Returns the \host for this request, such as "example.com".
      def raw_host_with_port
        if forwarded = env["HTTP_X_FORWARDED_HOST"]
          forwarded.split(/,\s?/).last
        else
          env['HTTP_HOST'] || "#{env['SERVER_NAME'] || env['SERVER_ADDR']}:#{env['SERVER_PORT']}"
        end
      end

      # Returns the host for this request, such as example.com.
      def host
        raw_host_with_port.sub(/:\d+$/, '')
      end

      # Returns a \host:\port string for this request, such as "example.com" or
      # "example.com:8080".
      def host_with_port
        "#{host}#{port_string}"
      end

      # Returns the port number of this request as an integer.
      def port
        @port ||= begin
          if raw_host_with_port =~ /:(\d+)$/
            $1.to_i
          else
            standard_port
          end
        end
      end

      # Returns the standard \port number for this request's protocol.
      def standard_port
        case protocol
          when 'https://' then 443
          else 80
        end
      end

      # Returns whether this request is using the standard port
      def standard_port?
        port == standard_port
      end

      # Returns a number \port suffix like 8080 if the \port number of this request
      # is not the default HTTP \port 80 or HTTPS \port 443.
      def optional_port
        standard_port? ? nil : port
      end

      # Returns a string \port suffix, including colon, like ":8080" if the \port
      # number of this request is not the default HTTP \port 80 or HTTPS \port 443.
      def port_string
        standard_port? ? '' : ":#{port}"
      end

      def server_port
        @env['SERVER_PORT'].to_i
      end

      # Returns the \domain part of a \host, such as "rubyonrails.org" in "www.rubyonrails.org". You can specify
      # a different <tt>tld_length</tt>, such as 2 to catch rubyonrails.co.uk in "www.rubyonrails.co.uk".
      def domain(tld_length = @@tld_length)
        ActionDispatch::Http::URL.extract_domain(host, tld_length)
      end

      # Returns all the \subdomains as an array, so <tt>["dev", "www"]</tt> would be
      # returned for "dev.www.rubyonrails.org". You can specify a different <tt>tld_length</tt>,
      # such as 2 to catch <tt>["www"]</tt> instead of <tt>["www", "rubyonrails"]</tt>
      # in "www.rubyonrails.co.uk".
      def subdomains(tld_length = @@tld_length)
        ActionDispatch::Http::URL.extract_subdomains(host, tld_length)
      end

      # Returns all the \subdomains as a string, so <tt>"dev.www"</tt> would be
      # returned for "dev.www.rubyonrails.org". You can specify a different <tt>tld_length</tt>,
      # such as 2 to catch <tt>"www"</tt> instead of <tt>"www.rubyonrails"</tt>
      # in "www.rubyonrails.co.uk".
      def subdomain(tld_length = @@tld_length)
        ActionDispatch::Http::URL.extract_subdomain(host, tld_length)
      end
    end
  end
end
