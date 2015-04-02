module Spotlight
  module Flickr
    module Resources
      class API
        class ImageSet
          delegate :page, :per_page, :pages, to: :images
          def initialize(json)
            @images_json = JSON.parse(json)
          end
          def images
            @images ||= if @images_json['photos']
              JSON.parse(@images_json['photos'].to_json, object_class: OpenStruct)
            elsif @images_json['photoset']
              JSON.parse(@images_json['photoset'].to_json, object_class: OpenStruct)
            end
          end
        end
      end
    end
  end
end
