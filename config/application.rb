require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsTutorial
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Set path to search locale files
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    # Set supported locales
    config.i18n.available_locales = [:en, :vi]

    # Set default locale
    config.i18n.default_locale = :en

    config.autoload_paths += %W["#{config.root}/app/validators/"]
    config.autoload_paths << Rails.root.join("lib")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_storage.variant_processor = :mini_magick

    config.active_job.queue_adapter = :sidekiq

    # Public the API, allow CORS
    # config.middleware.insert_before 0, "Rack::Cors" do
    #   allow do
    #       origins "*"
    #       resource "*", headers: :any, :methods => [:get, :post, :options]
    #   end
    # end
  end
end
