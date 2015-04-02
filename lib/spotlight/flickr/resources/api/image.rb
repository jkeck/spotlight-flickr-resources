module Spotlight
  module Flickr
    module Resources
      class API
        class Image
          delegate :title, :id, to: :json
          def initialize(json)
            @json = json
          end
          def url
            json.url_o
          end
          def tags
            Array(json.tags)
          end
          def description
            Hash[json.description._content.split("\n").map(&:chomp).reject(&:empty?).map do |entry|
              line = entry.split(': ').map(&:strip)
              [line[0], line[1..line.length].join]
            end]
          end
          private
          def json
            @json
          end
        end
      end
    end
  end
end
