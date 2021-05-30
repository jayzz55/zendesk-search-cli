# frozen_string_literal: true

require 'dry/monads'
require 'errors/unknown_search_term'
require 'services/fetch_schema'

module Validators
  class SearchTerm
    class << self
      include Dry::Monads[:result]

      def call(record:, search_term:)
        Services::FetchSchema.call(record: record).fmap(&:keys).bind do |keys|
          if keys.include?(search_term)
            Success()
          else
            Failure(
              Errors::UnknownSearchTerm.new(
                "unknown search term #{search_term} for the record #{record}"
              )
            )
          end
        end
      end
    end
  end
end
