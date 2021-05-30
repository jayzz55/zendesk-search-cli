# frozen_string_literal: true

require 'dry/monads'
require 'errors/unknown_schema_record'

module Services
  class FetchSchema
    class << self
      include Dry::Monads[:try, :result]

      def call(record:)
        case record
          in 'users' | 'organizations' | 'tickets' => matched_record
            Try { Object.const_get("#{matched_record.upcase}_SCHEMA") }
              .to_result
              .or(Failure(error("schema not found for #{record} record")))
          in _
            Failure(error("unknown #{record} record"))
        end
      end

      private

      def error(msg)
        Errors::UnknownSchemaRecord.new(msg)
      end
    end
  end
end
