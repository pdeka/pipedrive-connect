# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pipedrive::Deal, type: :resource do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
    allow(Pipedrive).to receive(:api_key).and_return("abc123")
  end

  describe "methods" do
    it "responds to fields" do
      expect(subject).to respond_to(:fields)
    end
    it "responds to products" do
      expect(subject).to respond_to(:products)
    end
    it "responds to merge" do
      expect(subject).to respond_to(:merge)
    end
  end

  describe "#add_product" do
    let(:product) { Pipedrive::Product.new(id: 1) }
    before do
      stubs.get("dealFields") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: [],
          }.to_json,
        ]
      end

      stubs.get("productFields") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: [],
          }.to_json,
        ]
      end

      stubs.post("deals/1/products") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: {
              id: 1,
              name: "Product",
            },
          }.to_json,
        ]
      end
    end

    context "missing or wrong params" do
      it "raises error when a product param of a wrong type is sent" do
        expect do
          subject.add_product("whatever", {})
        end.to raise_error(
          "Param *product* is not an instance of Pipedrive::Product"
        )
      end
      it "raises error when item price is missing" do
        expect do
          subject.add_product(product, {})
        end.to raise_error(
          "Param :item_price is required"
        )
      end
      it "raises error when quantity is missing" do
        expect do
          subject.add_product(product, { item_price: 1 })
        end.to raise_error(
          "Param :quantity is required"
        )
      end
    end

    context "valid" do
      subject { described_class.new(id: 1) }
      it "adds the product and returns its instance" do
        p = subject.add_product(product, item_price: 1, quantity: 1)
        expect(p).to be_a(Pipedrive::Product)
        expect(p.id).to be(1)
        expect(p.name).to eq("Product")
      end
    end
  end

  describe "#add_participant" do
    let(:person) { Pipedrive::Person.new(id: 1) }
    before do
      stubs.get("dealFields") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: [],
          }.to_json,
        ]
      end

      stubs.get("personFields") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: [],
          }.to_json,
        ]
      end

      stubs.post("deals/1/participants") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: [],
          }.to_json,
        ]
      end

      stubs.get("persons/1/deals") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: [{ id: 1 }],
          }.to_json,
        ]
      end
    end

    context "missing or wrong params" do
      it "raises error when a participant param of a wrong type is sent" do
        expect do
          subject.add_participant("whatever")
        end.to raise_error(
          "Param *participant* is not an instance of Pipedrive::Person"
        )
      end
    end

    context "valid" do
      subject { described_class.new(id: 1) }
      it "adds the deal to the Person" do
        subject.add_participant(person)
        expect(person.deals.length).to eq(1)
        # TODO:  Add check that it's the correct deal. ID = 1
      end
    end
  end

  describe "#delete_attached_product" do
    subject { described_class.new(id: 1) }
    let(:product_attachment_id) { 1 }
    before do
      stubs.delete("deals/#{subject.id}/products/#{product_attachment_id}") do
        [
          200,
          { "Content-Type": "application/json" },
          {
            success: true,
            data: {
              id: 1,
              name: "Product",
            },
          }.to_json,
        ]
      end
    end

    it "deletes the attached product and returns true" do
      expect(subject.delete_attached_product(product_attachment_id)).to be_truthy
    end
  end
end
