# frozen_string_literal: true

require 'schema'
require 'time'
require 'dry/monads'
require 'models/database'
require 'errors/generate_database'
require 'services/fetch_schema'
require 'parsers/search_value'

DEFAULT_SCHEMA_GETTER = ->(record) { Services::FetchSchema.call(record: record) }

module Services
  class GenerateDatabase
    @database = nil

    class << self
      include Dry::Monads[:try, :result]

      def call(input, schema_getter = DEFAULT_SCHEMA_GETTER)
        Try do
          @database = Models::Database.new

          input.each do |record, json_data|
            schema = get_schema!(schema_getter, record)
            primary_key = primary_key_from(schema)

            @database.add_schema(record: record, schema: schema)

            json_data.each do |row_data|
              process_row_data!(schema, record, primary_key, row_data)
            end
          end

          @database
        end.to_result
      end

      private

      def process_row_data!(schema, record, primary_key, row_data)
        validate_primary_key_exists!(primary_key, row_data)
        validate_data_against_schema!(schema, row_data)

        index = row_data[primary_key]
        primary_key_type = schema.dig(primary_key, 'type')

        insert_row!(record, primary_key_type, index, row_data)
        insert_indexes!(schema.except(primary_key), record, row_data, index)
      end

      def insert_row!(record, primary_key_type, index, row_data)
        @database.upsert_record(
          record: record, primary_key: parse_value!(index, primary_key_type), value: row_data
        )
      end

      def insert_indexes!(schema, record, row_data, index)
        schema.each do |key, attributes|
          type = attributes['type']
          value = row_data[key]

          if value.nil?
            insert_index!('String', record, key, '', index)
          else
            insert_index!(type, record, key, value, index)
          end
        end
      end

      def insert_index!(type, record, key, value, index)
        case type
          in /Array/
            value.each do |each_value|
              each_type = type.gsub('Array[', '').gsub(']', '')
              @database.insert_index(record: record, paths: [key, *parse_value!(each_value, each_type)], index: index)
            end
          in _
            @database.insert_index(record: record, paths: [key, *parse_value!(value, type)], index: index)
        end
      end

      def get_schema!(schema_getter, record)
        schema_getter
          .call(record)
          .value_or { raise Errors::GenerateDatabase, "unknown '#{record}' record error" }
      end

      def parse_value!(value, type)
        Parsers::SearchValue
          .call(value: value, type: type)
          .value_or { raise Errors::GenerateDatabase, "provided value #{value} for type #{type} is invalid" }
      end

      def primary_key_from(schema)
        schema.select { |attr| schema.dig(attr, 'primary_key') }.keys.first
      end

      def validate_primary_key_exists!(primary_key, data)
        raise Errors::GenerateDatabase, "primary_key is not found in #{data}" if data[primary_key].nil?
      end

      def validate_data_against_schema!(schema, row_data)
        unknown_attributes = row_data.keys - schema.keys

        return if unknown_attributes.empty?

        raise Errors::GenerateDatabase, "unknown attributes #{unknown_attributes} provided"
      end
    end
  end
end
