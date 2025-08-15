# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'devise'
require 'database_cleaner/active_record'

# Auto-load support files
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Maintain test schema
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # FactoryBot
  config.include FactoryBot::Syntax::Methods
  # Devise helpers for request specs
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Fixtures (if used)
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # --- DatabaseCleaner Setup ---
  config.before(:suite) do
    DatabaseCleaner.allow_remote_database_url = true if Rails.env.test?
    DatabaseCleaner.clean_with(:truncation)
  end

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation) # Clean DB at the start
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    # Flush Redis too
    $redis.flushdb if defined?($redis)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Automatically infer spec type from file location
  config.infer_spec_type_from_file_location!
  # Clean backtraces
  config.filter_rails_from_backtrace!
end
