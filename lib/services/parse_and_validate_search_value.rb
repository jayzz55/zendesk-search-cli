# frozen_string_literal: true

require 'dry/monads'
require 'parsers/search_value'
require 'errors/invalid_search_value'

module Services
  class ParseAndValidateSearchValue
    class << self
      include Dry::Monads[:result]

      def call(type:, value:)
        Parsers::SearchValue
          .call(type: type, value: value)
          .to_result(Errors::InvalidSearchValue.new("search value #{value} is invalid"))
      end
    end
  end
end
