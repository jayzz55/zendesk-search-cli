# frozen_string_literal: true

require 'dry/monads'
require 'errors/unknown_search_term'
require 'services/fetch_schema'

module Validators
  class SearchTerm
    class << self
      include Dry::Monads[:result]

      def call(search_terms:, value:)
        if search_terms.include?(value)
          Success()
        else
          Failure(
            Errors::UnknownSearchTerm.new(
              "unknown search term #{value} provided"
            )
          )
        end
      end
    end
  end
end
