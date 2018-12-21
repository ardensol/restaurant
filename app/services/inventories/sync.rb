require 'open-uri'

module Inventories
  class Sync
    include HTTParty

    EEL_BASE_URL = 'https://eel-inventory.herokuapp.com'.freeze


    def execute
      results = inventory_response['results']
      return unless results.present?

      Spree::Product.where.not(eel_inventory_id: nil)
        .update_all(
          archived: true,
          available_on: nil
        )

      results.each do |result|
        next unless result['category'] &&
        next unless (name = result['category']['name'])
        next unless (taxon = Spree::Taxon.find_by(name: name))

        inventory =
          Spree::Product.find_or_initialize_by(
            eel_inventory_id: result['id'].to_s
          )
        inventory.assign_attributes(
          name: result['name'],
          price: result['suggested_retail_price'],
          shipping_category_id: 1,
          taxon_ids: [taxon.id],
          description: result['external_description'],
          archived: false,
          available_on: Time.now
        )


        inventory.images.destroy_all if inventory.persisted?
        inventory.product_properties.destroy_all if inventory.persisted?

        inventory.save!


        if result['images'].present? && result['images'].size > 0
          result['images'].each do |image|
            im = inventory.images.build(
              s3_url: "https://#{clean_file(image['attachment_file_name'])}"
            )

            im.attachment = URI.parse(im.s3_url)

            im.save
          end
        end

        properties = result.slice(
          'brand', 'model', 'voltage', 'height', 'width', 'length'
        )

        properties = properties.select { |_k, v| v.present? }

        properties.each do |prop, value|
          property = Spree::Property.find_or_initialize_by(name: prop)
          property.update!(presentation: prop.capitalize) unless property.persisted?


          product_property =
            Spree::ProductProperty.new(
              product: inventory, property: property, value: value
            )
          product_property.save!
        end
      end
    end

    private

    def inventory_response
      @inventory_response ||=
        HTTParty
        .get("#{EEL_BASE_URL}/api/v1/inventories", headers: headers)
        .parsed_response
    end

    def headers
      {
        'Content-Type' => 'application/json'
      }
    end

    def clean_file(name)
      %w[https:// http://].inject(name) do |result, word|
        return '' unless result
        result.gsub(word, '').gsub(' ', '')
      end
    end

    def download_image(url, dest)
      open(url) do |u|
        File.open(dest, 'wb') { |f| f.write(u.read) }
      end
    end
  end
end