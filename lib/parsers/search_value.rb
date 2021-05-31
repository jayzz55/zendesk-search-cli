# frozen_string_literal: true

require 'dry/monads'
require 'parsers/time_attributes'

module Parsers
  class SearchValue
    class << self
      include Dry::Monads[:maybe, :try]

      def call(type:, value:)
        case type
          in nil
            None()
          in /Integer/
            parse_integer(value)
          in /Boolean/
            parse_boolean(value)
          in /Time/
            parse_time(value)
          in /String/
            Some(value.downcase)
          in _
            None()
        end
      end

      private

      def parse_integer(value)
        Try[ArgumentError] { Integer(value) }.to_maybe
      end

      def parse_boolean(value)
        case value
          in 'true'
            Some(true)
          in 'false'
            Some(false)
          in _
            None()
        end
      end

      def parse_time(value)
        Parsers::TimeAttributes.call(value: value)
      end
    end
  end
end
