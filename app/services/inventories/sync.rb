require 'open-uri'

module Inventories
  class Sync
    include HTTParty

    EEL_BASE_URL = 'https://eel-inventory.herokuapp.com'.freeze

    def execute_single(inventory)
      if inventory['status'] != 'in_stock'
        destroy_inventory(inventory)
      else
        create_inventory(inventory)
      end
    end

    def execute
      # results = inventory_response['results']
      return unless results.present?

      Spree::Product.unscoped.where.not(eel_inventory_id: nil)
        .update_all(
          archived: true,
          available_on: nil,
          deleted_at: Time.now
        )

      results.each do |result|
        begin
          create_inventory(result)
        rescue => e
          Rails.logger.info("ERROR ERROR #{e.message}")
          p e
        end
      end
    end

    private

    def destroy_inventory(result)
      inventory =
        Spree::Product.unscoped.find_or_initialize_by(
          eel_inventory_id: result['id'].to_s
        )

      inventory.update(
        archived: true,
        available_on: nil,
        deleted_at: Time.now
      )
    end

    def create_inventory(result)
      return unless result['category']
      return unless (name = result['category']['name'])
      return unless (taxon = Spree::Taxon.where("name ILIKE ?", name.strip))
      inventory =
        Spree::Product.unscoped.find_or_initialize_by(
          eel_inventory_id: result['id'].to_s
        )
      inventory.assign_attributes(
        name: result['name'],
        price: result['suggested_retail_price'].to_f,
        shipping_category_id: 1,
        taxon_ids: [taxon.id],
        description: result['external_description'],
        archived: false,
        available_on: Time.now - 3.days,
        deleted_at: nil
      )

      inventory.images.destroy_all if inventory.persisted?
      inventory.product_properties.destroy_all if inventory.persisted?
      inventory.save!

      if result['images'].present? && result['images'].size.positive?
        result['images'].each_with_index do |image, idx|
          next unless image['display']
          im = inventory.images.build(
            s3_url: "https://#{clean_file(image['attachment_file_name'])}"
          )
          im.attachment = URI.parse(im.s3_url)
          im.save

          im.update_column :position, idx + 1
          im.attachment.reprocess!
        end
      end

      properties = result.slice(
        'model', 'voltage', 'internal_id'
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

      dims = result.slice('height', 'width', 'length')

      if dims.all?(&:present?)
        prop = Spree::Property.find_or_initialize_by(name: 'dimensions')
        prop.update!(presentation: 'Dimensions') unless prop.persisted?
        product_property =
          Spree::ProductProperty.new(
            product: inventory,
            property: prop,
            value: "#{result['length']}L X #{result['width']}W X #{result['height']}H"
          )

        product_property.save!
      end

    end

    def inventory_response
      @inventory_response ||=
        HTTParty.get("#{EEL_BASE_URL}/api/v1/inventories", headers: headers).parsed_response
    end

    def post_updates(inventory)
      HTTParty.post(
        params: {
          id: inventory.eel_inventory_id,
          website_url: "http://www.eeleconomicrestaurantequipment.com/products/"\
            "#{inventory.slug}"
        }
      )
    end

    def headers
      {
        'Content-Type' => 'application/json'
      }
    end

    def clean_file(name)
      %w[https:// http://].inject(name) do |result, word|
        return '' unless result
        result.gsub(word, '').delete(' ')
      end
    end

    def download_image(url, dest)
      open(url) do |u|
        File.open(dest, 'wb') { |f| f.write(u.read) }
      end
    end
  end
end