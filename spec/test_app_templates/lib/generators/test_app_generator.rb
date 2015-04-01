require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "../../spec/test_app_templates"

  def add_gems
    gem 'blacklight', ">= 5.4.0.rc1", "<6"
    gem "blacklight-gallery", ">= 0.3.0"
    gem "sir_trevor_rails", github: "sul-dlss/sir-trevor-rails"
    gem "blacklight-spotlight", github: "sul-dlss/spotlight"
    gem "jettywrapper"
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def run_blacklight_generator
    generate 'blacklight:install', '--devise'
  end
  
  def add_spotlight_routes_and_assets
    generate 'spotlight:install', '-f --mailer_default_url_host=localhost:3000'
  end

  def run_spotlight_migrations
    rake "spotlight:install:migrations"
    rake "db:migrate"
  end

end
