# frozen_string_literal: true

class Repository
  attr_reader :database

  def initialize(database)
    @database = database
  end

  def available_records
    database.available_records
  end
end
