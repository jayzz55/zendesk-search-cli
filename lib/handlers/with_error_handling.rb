# frozen_string_literal: true

require 'dry/monads'

module Handlers
  class WithErrorHandling
    class << self
      include Dry::Monads[:try]

      def call(output: $stdout, &block)
        result = Try(&block).to_result.flatten
        return :ok if result.success?

        case result.failure
        when :quit
          output.puts 'exiting.. Goodbye'

          :ok
        else
          output.puts 'Oops, this is embarassing, some unexpected error has occured.'

          :error
        end
      end
    end
  end
end
