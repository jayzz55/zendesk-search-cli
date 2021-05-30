# frozen_string_literal: true

module Models
  class Database
    attr_reader :data

    def initialize(data = {})
      @data = data
    end

    def available_records
      data.keys
    end

    def get_record(record:, key:)
      data.dig(record, key)
    end

    def search_index(record:, paths:)
      data.dig(record, 'index', *paths).to_a
    end

    def upsert_record(record:, primary_key:, value:)
      upsert([record, primary_key], value)
    end

    def upsert_index(record:, paths:, index:)
      new_record_ids = search_index(record: record, paths: paths).to_a + [index]

      upsert([record, 'index', *paths], new_record_ids.uniq)
    end

    private

    attr_writer :data

    def upsert(keys, value, obj = data)
      key = keys.first
      if keys.length == 1
        obj[key] = value
      else
        obj[key] = {} unless obj[key]
        upsert(keys.slice(1..-1), value, obj[key])
      end
    end
  end
end
