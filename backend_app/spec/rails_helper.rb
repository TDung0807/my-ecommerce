# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'devise'

# Auto-load support files
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Maintain test schema
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.before(:each, type: :request) do
    host! "localhost"
  end
  # If using fixtures (optional)
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true

  # Automatically infer spec type from file location (recommended)
  config.infer_spec_type_from_file_location!

  # Clean backtraces
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")
end
