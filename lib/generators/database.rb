# frozen_string_literal: true

require 'schema'
require 'time'
require 'dry/monads'
require 'models/database'
require 'errors/generate_database'

module Generators
  class Database
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
              raise Errors::GenerateDatabase, "unknown schema #{key} error"
            in 'Integer' if schema.dig(key, 'primary_key')
              @database.upsert_record(record: record, primary_key: value.to_i, value: data)
            in 'String' if schema.dig(key, 'primary_key')
              @database.upsert_record(record: record, primary_key: value.to_s, value: data)
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
            raise Errors::GenerateDatabase, "unknown #{record} record error"
        end
      end

      def time_attributes_from(value)
        time = Time.parse(value).utc
        [time.year, time.month, time.day, time.hour, time.min, time.sec]
      rescue ArgumentError
        ['']
      end

      def primary_key_from(schema)
        schema.select { |attr| schema.dig(attr, 'primary_key') }.keys.first
      end
    end
  end
end
