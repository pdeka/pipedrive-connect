# frozen_string_literal: true

module Pipedrive
  class Deal < Resource
    include Fields
    include Merge

    has_many :products, class_name: "Product"

    # POST /deals/:id/products
    # Add a product to this deal
    def add_product(product, params)
      raise "Param *product* is not an instance of Pipedrive::Product" \
        unless product.is_a?(Pipedrive::Product)
      raise "Param :item_price is required" unless params.key?(:item_price)
      raise "Param :quantity is required" unless params.key?(:quantity)

      response = request(
        :post,
        "#{resource_url}/products",
        params.merge(id: id, product_id: product.id)
      )
      Product.new(response[:data])
    end

    # POST /deals/:id/participants
    def add_participant(participant)
      raise "Param *participant* is not an instance of Pipedrive::Person" \
        unless participant.is_a?(Pipedrive::Person)

      request(
        :post,
        "#{resource_url}/participants",
        { id: id, person_id: participant.id }
      )

      # Add deal to the person
      participant.deals << self
    end

    # DELETE /deals/:id/products/:product_attachment_id
    # Detach a product from this deal
    def delete_attached_product(product_attachment_id)
      response = request(:delete, "#{resource_url}/products/#{product_attachment_id}")
      response[:success]
    end
  end
end
