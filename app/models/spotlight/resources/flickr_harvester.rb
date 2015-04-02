module Spotlight::Resources
  class FlickrHarvester < Spotlight::Resource
    self.weight = -5000

    after_save :harvest_resources
    
    def self.can_provide?(res)
      Spotlight::Flickr::Resources::Engine.config.flickr_api_key.present? && ['user', 'photoset'].include?(res.resource_type)
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
      @items ||= Spotlight::Flickr::Resources::API.new(type: resource_type, value: url).images
    end

    def convert_entry_to_solr_hash(x)
      h = { 
        exhibit.blacklight_config.document_model.unique_key.to_sym => compound_id(x),
        title_field => x.title, 
        url: x.url
      }
      
      # TODO: Add tags the correct way
      # tags = x.tags

      content = x.description
      create_sidecars_for(*content.keys)

      content.each_with_object(h) do |(key, value), hash|
        if(field = exhibit_custom_fields[key])
          h[field.field] = value
        end
      end
    end

    def compound_id(x)
      x.id
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