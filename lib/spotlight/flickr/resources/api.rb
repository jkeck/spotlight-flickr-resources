module Spotlight
  module Flickr
    module Resources
      require 'spotlight/flickr/resources/api/image'
      require 'spotlight/flickr/resources/api/image_set'
      class API
        def initialize(type:,value:)
          @type = type
          @value = value
        end

        def images
          @images ||= begin
            objects = []
            photos = fetch_image_set
            max_pages(photos.pages).to_i.times do
              objects.append(photos.images.photo)
              unless photos.page.to_i == max_pages(photos.pages).to_i
                photos = fetch_image_set(photos.page.to_i + 1)
              end
            end
            objects.flatten.map do |object|
              Image.new(object)
            end
          end
        end

        def max_pages(pages)
          if Spotlight::Flickr::Resources::Engine.config.flickr_max_pages &&
               Spotlight::Flickr::Resources::Engine.config.flickr_max_pages.to_i < pages.to_i
            Spotlight::Flickr::Resources::Engine.config.flickr_max_pages
          else
            pages
          end
        end

        def fetch_image_set(page=1)
          ImageSet.new(Faraday.get(api_url(page)).body)
        end
        def api_url(page)
          "#{api_base}?method=#{api_method}&api_key=#{api_key}&extras=#{extras}&format=#{format}&nojsoncallback=1&#{api_parameter}=#{@value}&page=#{page}"
        end
        def api_base
          'https://api.flickr.com/services/rest/'
        end
        def format
          'json'
        end
        def extras
          ['url_o', 'tags', 'description'].join('%2C+')
        end
        def api_method
          case @type
          when 'photoset'
            'flickr.photosets.getPhotos'
          else
            'flickr.people.getPhotos'
          end
        end
        def api_parameter
          case @type
          when 'photoset'
            'photoset_id'
          else
            'user_id'
          end
        end
        def api_key
          Spotlight::Flickr::Resources::Engine.config.flickr_api_key
        end
      end
    end
  end
end
