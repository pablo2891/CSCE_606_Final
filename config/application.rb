require_relative "boot"

require "rails/all"

# if ENV["RAILS_ENV"] == "development" || ENV["RACK_ENV"] == "development"
#   begin
#     if defined?(ActionMailer::Base)
#       ActionMailer::Base.singleton_class.class_eval do
#         unless method_defined?(:preview_path=) || respond_to?(:preview_path=)
#           define_method(:preview_path=) do |path|
#             self.preview_paths = Array(path)
#           end
#         end

#         unless method_defined?(:preview_path) || respond_to?(:preview_path)
#           define_method(:preview_path) do
#             Array(self.preview_paths).first
#           end
#         end
#       end
#     end
#   rescue => e
#     warn "action_mailer preview shim failed: #{e.class}: #{e.message}"
#   end
# end


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Project3
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
