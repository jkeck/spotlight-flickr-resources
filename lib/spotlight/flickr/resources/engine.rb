require 'spotlight/engine'
module Spotlight
  module Flickr
    module Resources
      class Engine < ::Rails::Engine
        Spotlight::Flickr::Resources::Engine.config.flickr_api_key = nil
        Spotlight::Flickr::Resources::Engine.config.flickr_max_pages = nil
        Spotlight::Flickr::Resources::Engine.config.resource_partials = ['spotlight/resources/flickr/user', 'spotlight/resources/flickr/album']
        initializer "spotlight.flickr.initialize" do
          if Spotlight::Flickr::Resources::Engine.config.flickr_api_key.present?
            Spotlight::Engine.config.resource_providers << Spotlight::Resources::FlickrHarvester

            Spotlight::Engine.config.new_resource_partials ||= []
            Spotlight::Engine.config.new_resource_partials << 'spotlight/resources/flickr/tabbed_form'
          end
        end
      end
    end
  end
end

