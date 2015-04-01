require 'flickr'
module Spotlight::Resources
  class FlickrHarvester < Spotlight::Resource
    self.weight = -5000

    after_save :harvest_resources
    
    def self.can_provide?(res)
      Spotlight::Flickr::Resources::Engine.config.flickr_api_key.present? && !!(res.url =~ /^https?:\/\/(w{3}\.|)flickr\.com\//)
    end

    def update_index(data)
      data = [data] unless data.is_a? Array
      blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json'} unless data.empty?
    end
   
    def to_solr
      []
    end

    def harvest_resources
      items.each do |x|
        h = convert_entry_to_solr_hash(x)
        puts "creating #{h.inspect}"
        Spotlight::Resources::Upload.create(
          remote_url_url: h[:url],
          data: h,
          exhibit: exhibit
        ) if h[:url]
      end
    end

    def items
      @items ||= begin
        objects = []
        photos = fetch
        while photos.page.to_i <= max_pages(photos.pages).to_i
          photos.each do |photo|
            objects << photo
          end
          photos = fetch(photos.page.to_i + 1)
        end
        objects
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

    def convert_entry_to_solr_hash(x)
      h = { 
        exhibit.blacklight_config.document_model.unique_key.to_sym => compound_id(x),
        title_field => x.title, 
        url: x.source('Large')
      }
      
      # TODO: Add tags the correct way
      # tags = tags_array(x)
      # h['tags'] = tags if tags.present?

      content = description_content(x)
      create_sidecars_for(*content.keys)

      content.each_with_object(h) do |(key, value), hash|
        h[exhibit_custom_fields[key].field] = value
      end
    end

    def description_content(image)
      Hash[image.description.split("\n").map(&:chomp).reject(&:empty?).map do |entry|
        line = entry.split(': ').map(&:strip)
        [line[0], line[1..line.length].join]
      end]
    end

    def tags_array(image)
      if (tags = image.tags['tag'])
        tags = [tags] unless tags.is_a?(Array)
        tags.map{ |t| t['raw'] }
      end
    end

    def compound_id(x)
      x.id
    end

    def fetch(page=1)
      flickr_user.photos(page: page)
    end

    def flickr_user
      @flickr_user ||= flickr_api.find_by_url(url)
    end

    def flickr_api
      @flickr_api ||= Flickr.new(Spotlight::Flickr::Resources::Engine.config.flickr_api_key)
    end

    def title_field
      Spotlight::Engine.config.upload_title_field || exhibit.blacklight_config.index.title_field
    end
    
    def create_sidecars_for(*keys)
      missing = keys - exhibit.custom_fields.map { |x| x.label }

      missing.each do |k|
        exhibit.custom_fields.create! label: k
      end.tap { @exhibit_custom_fields = nil }
    end

    def exhibit_custom_fields
      @exhibit_custom_fields ||= exhibit.custom_fields.each_with_object({}) do |value, hash|
        hash[value.label] = value
      end
    end
  end
end