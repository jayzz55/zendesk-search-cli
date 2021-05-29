# frozen_string_literal: true

require 'schemas'
require 'time'
require 'dry/monads'
require 'models/database'
require 'models/error'

module Services
  class GenerateDatabase
    @database = nil

    class << self
      include Dry::Monads[:try, :result]

      def call(input)
        Try do
          @database = Models::Database.new

          input.each do |record, json_data|
            schema = get_schema!(record)
            primary_key = primary_key_from(schema)

            json_data.each do |row_data|
              insert_row!(record, row_data, schema, primary_key)
            end
          end

          @database
        end.to_result
      end

      private

      def insert_row!(record, data, schema, primary_key)
        data.each do |key, value|
          case schema.dig(key, 'type')
            in nil
              raise Models::GenerateDatabaseError, "unknown schema #{key} error"
            in 'PrimaryKey'
              @database.upsert_record(record: record, primary_key: value, value: data)
            in _ => matched_type
              upsert_index(matched_type, record, key, value, data[primary_key])
          end
        end
      end

      def upsert_index(type, record, key, value, index)
        case type
          in 'Array[String]'
            value.each { |val| upsert_index_for_string_value(record, key, val, index) }
          in 'Time'
            @database.upsert_index(record: record, paths: [key, *time_attributes_from(value)], index: index)
          in 'String'
            upsert_index_for_string_value(record, key, value, index)
          in 'Boolean'
            @database.upsert_index(record: record, paths: [key, value == true], index: index)
          in _
            @database.upsert_index(record: record, paths: [key, value], index: index)
        end
      end

      def upsert_index_for_string_value(record, key, value, index)
        @database.upsert_index(record: record, paths: [key, value.to_s.downcase], index: index)
      end

      def get_schema!(record)
        case record
          in 'users' | 'organizations' | 'tickets' => matched_record
            Object.const_get("#{matched_record.upcase}_SCHEMA")
          in _
            raise Models::GenerateDatabaseError, "unknown#{key} record error"
        end
      end

      def time_attributes_from(value)
        time = Time.parse(value).utc
        [time.year, time.month, time.day, time.hour, time.min, time.sec]
      rescue ArgumentError
        ['']
      end

      def primary_key_from(schema)
        schema.select { |attr| schema.dig(attr, 'type') == 'PrimaryKey' }.keys.first
      end
    end
  end
end
