Ruby on Rails 4.2 Release Notes
===============================

Highlights in Rails 4.2:

These release notes cover only the major changes. To know about various bug
fixes and changes, please refer to the change logs or check out the
[list of commits](https://github.com/rails/rails/commits/master) in the main
Rails repository on GitHub.

--------------------------------------------------------------------------------

Upgrading to Rails 4.2
----------------------

If you're upgrading an existing application, it's a great idea to have good test
coverage before going in. You should also first upgrade to Rails 4.1 in case you
haven't and make sure your application still runs as expected before attempting
an update to Rails 4.2. A list of things to watch out for when upgrading is
available in the
[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)
guide.


Major Features
--------------

### Foreign key support

The migration DSL now supports adding and removing foreign keys. They are dumped
to `schema.rb` as well. At this time, only the `mysql`, `mysql2` and `postgresql`
adapters support foreign keys.

```ruby
# add a foreign key to `articles.author_id` referencing `authors.id`
add_foreign_key :articles, :authors

# add a foreign key to `articles.author_id` referencing `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# remove the foreign key on `accounts.branch_id`
remove_foreign_key :accounts, :branches

# remove the foreign key on `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

See the API documentation on
[add_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
and
[remove_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
for a full description.


Railties
--------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md)
for detailed changes.

### Removals

* The `rails application` command has been removed without replacement.
  ([Pull Request](https://github.com/rails/rails/pull/11616))

### Notable changes

* Introduced `bin/setup` script to bootstrap an application.
  ([Pull Request](https://github.com/rails/rails/pull/15189))

* Changed default value for `config.assets.digest` to `true` in development.
  ([Pull Request](https://github.com/rails/rails/pull/15155))

* Introduced an API to register new extensions for `rake notes`.
  ([Pull Request](https://github.com/rails/rails/pull/14379))

* Introduced `Rails.gem_version` as a convenience method to return `Gem::Version.new(Rails.version)`.
  ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md)
for detailed changes.

### Deprecations

* Deprecated support for setting the `to:` option of a router to a symbol or a
  string that does not contain a `#` character:

      get '/posts', to: MyRackApp    => (No change necessary)
      get '/posts', to: 'post#index' => (No change necessary)
      get '/posts', to: 'posts'      => get '/posts', controller: :posts
      get '/posts', to: :index       => get '/posts', action: :index

  ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

### Notable changes

* The `*_filter` family methods has been removed from the documentation. Their
  usage are discouraged in favor of the `*_action` family methods:

      after_filter          => after_action
      append_after_filter   => append_after_action
      append_around_filter  => append_around_action
      append_before_filter  => append_before_action
      around_filter         => around_action
      before_filter         => before_action
      prepend_after_filter  => prepend_after_action
      prepend_around_filter => prepend_around_action
      prepend_before_filter => prepend_before_action
      skip_after_filter     => skip_after_action
      skip_around_filter    => skip_around_action
      skip_before_filter    => skip_before_action
      skip_filter           => skip_action_callback

  If your application is depending on these methods, you should use the
  replacement `*_action` methods instead. These methods will be deprecated in
  the future and eventually removed from Rails.
  (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
  [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

* Added HTTP method `MKCALENDAR` from RFC-4791
  ([Pull Request](https://github.com/rails/rails/pull/15121))

* `*_fragment.action_controller` notifications now include the controller and action name
  in the payload.
  ([Pull Request](https://github.com/rails/rails/pull/14137))

* Segments that are passed into URL helpers are now automatically escaped.
  ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

* Improved Routing Error page with fuzzy matching for route search.
  ([Pull Request](https://github.com/rails/rails/pull/14619))

* Added option to disable logging of CSRF failures.
  ([Pull Request](https://github.com/rails/rails/pull/14280))


Action View
-------------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md)
for detailed changes.

### Deprecations

* Deprecated `AbstractController::Base.parent_prefixes`.
  Override `AbstractController::Base.local_prefixes` when you want to change
  where to find views.
  ([Pull Request](https://github.com/rails/rails/pull/15026))

* Deprecated `ActionView::Digestor#digest(name, format, finder, options = {})`,
  arguments should be passed as a hash instead.
  ([Pull Request](https://github.com/rails/rails/pull/14243))

### Notable changes


Action Mailer
-------------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md)
for detailed changes.

### Notable changes


Active Record
-------------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md)
for detailed changes.

### Removals

* Removed deprecated method `ActiveRecord::Base.quoted_locking_column`.
  ([Pull Request](https://github.com/rails/rails/pull/15612))

* Removed deprecated `ActiveRecord::Migrator.proper_table_name`. Use the
  `proper_table_name` instance method on `ActiveRecord::Migration` instead.
  ([Pull Request](https://github.com/rails/rails/pull/15512))

* Removed `cache_attributes` and friends. All attributes are cached.
  ([Pull Request](https://github.com/rails/rails/pull/15429))

* Removed unused `:timestamp` type. Transparently alias it to `:datetime`
  in all cases. Fixes inconsistencies when column types are sent outside of
  `ActiveRecord`, such as for XML Serialization.
  ([Pull Request](https://github.com/rails/rails/pull/15184))

### Deprecations

* Deprecated returning `nil` from `column_for_attribute` when no column exists.
  It will return a null object in Rails 5.0
  ([Pull Request](https://github.com/rails/rails/pull/15878))

* Deprecated `serialized_attributes` without replacement.
  ([Pull Request](https://github.com/rails/rails/pull/15704))

* Deprecated using `.joins`, `.preload` and `.eager_load` with associations that
  depends on the instance state (i.e. those defined with a scope that takes an
  argument) without replacement.
  ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

* Deprecated passing Active Record objects to `.find` or `.exists?`. Call `#id`
  on the objects first.
  (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
  [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

* Deprecated half-baked support for PostgreSQL range values with excluding
  beginnings. We currently map PostgreSQL ranges to Ruby ranges. This conversion
  is not fully possible because the Ruby range does not support excluded
  beginnings.

  The current solution of incrementing the beginning is not correct and is now
  deprecated. For subtypes where we don't know how to increment (e.g. `#succ`
  is not defined) it will raise an `ArgumentError` for ranges with excluding
  beginnings.

  ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

* Deprecated broken support for automatic detection of counter caches on
  `has_many :through` associations. You should instead manually specify the
  counter cache on the `has_many` and `belongs_to` associations for the through
  records.
  ([Pull Request](https://github.com/rails/rails/pull/15754))

### Notable changes

* Added support for `#pretty_print` in `ActiveRecord::Base` objects.
  ([Pull Request](https://github.com/rails/rails/pull/15172))

* PostgreSQL and SQLite adapters no longer add a default limit of 255 characters
  on string columns.
  ([Pull Request](https://github.com/rails/rails/pull/14579))

* `sqlite3:///some/path` now resolves to the absolute system path `/some/path`.
  For relative paths, use `sqlite3:some/path` instead. (Previously, `sqlite3:///some/path`
  resolved to the relative path `some/path`. This behaviour was deprecated on
  Rails 4.1.)
  ([Pull Request](https://github.com/rails/rails/pull/14569))

* Introduced `#validate` as an alias for `#valid?`.
  ([Pull Request](https://github.com/rails/rails/pull/14456))

* `#touch` now accepts multiple attributes to be touched at once.
  ([Pull Request](https://github.com/rails/rails/pull/14423))

* Added support for fractional seconds for MySQL 5.6 and above.
  (Pull Request [1](https://github.com/rails/rails/pull/8240), [2](https://github.com/rails/rails/pull/14359))

* Added support for the `citext` column type in PostgreSQL adapter.
  ([Pull Request](https://github.com/rails/rails/pull/12523))

* Added support for user-created range types in PostgreSQL adapter.
  ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

Active Model
------------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md)
for detailed changes.

### Removals

* Removed deprecated `Validator#setup` without replacement.
  ([Pull Request](https://github.com/rails/rails/pull/15617))

### Notable changes

* Introduced `#validate` as an alias for `#valid?`.
  ([Pull Request](https://github.com/rails/rails/pull/14456))


Active Support
--------------

Please refer to the
[Changelog](https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md)
for detailed changes.

### Removals

* Removed deprecated `Numeric#ago`, `Numeric#until`, `Numeric#since`,
  `Numeric#from_now`. ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

* Removed deprecated string based terminators for `ActiveSupport::Callbacks`.
  ([Pull Request](https://github.com/rails/rails/pull/15100))

### Deprecations

* Deprecated `Class#superclass_delegating_accessor`, use `Class#class_attribute`
  instead. ([Pull Request](https://github.com/rails/rails/pull/14271))

* Deprecated `ActiveSupport::SafeBuffer#prepend!` as `ActiveSupport::SafeBuffer#prepend`
  now performs the same function. ([Pull Request](https://github.com/rails/rails/pull/14529))

### Notable changes

* The `humanize` inflector helper now strips any leading underscores.
  ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

* Added `SecureRandom::uuid_v3` and `SecureRandom::uuid_v5`.
  ([Pull Request](https://github.com/rails/rails/pull/12016))

* Introduce `Concern#class_methods` as an alternative to `module ClassMethods`,
  as well as `Kernel#concern` to avoid the `module Foo; extend ActiveSupport::Concern; end`
  boilerplate. ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

Credits
-------

See the
[full list of contributors to Rails](http://contributors.rubyonrails.org/) for
the many people who spent many hours making Rails, the stable and robust
framework it is. Kudos to all of them.
