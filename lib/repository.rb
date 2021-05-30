# frozen_string_literal: true

class Repository
  attr_reader :database

  def initialize(database)
    @database = database
  end
end


