# frozen_string_literal: true

module Pipedrive
  class Person < Resource
    include Fields
    include Merge

    has_many :deals, class_name: "Deal"
    has_many :activities, class_name: "Activity"

    # GET /api/v2/persons/search
    def self.search(term, exact_match)
      params = { term: term }
      params = params.merge({ exact_match: 1 }) if exact_match
      response = request(
        :get,
        "#{resource_url}/search",
        params
      )
      items = response[:data]

      return [] if items.nil?

      items.map { |d| new(d) }
    end

  end
end
