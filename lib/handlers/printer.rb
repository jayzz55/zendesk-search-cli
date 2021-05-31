# frozen_string_literal: true

require 'models/user'
require 'models/organization'
require 'models/ticket'

module Handlers
  class Printer
    attr_reader :output

    def initialize(output = $stdout)
      @output = output
    end

    def puts(input)
      case input
        in Array
        input.each { |value| puts(value) }
        in _
        output.puts input
      end
    end
  end
end
