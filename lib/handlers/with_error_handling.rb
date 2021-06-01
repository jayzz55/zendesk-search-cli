# frozen_string_literal: true

require 'dry/monads'

module Handlers
  class WithErrorHandling
    class << self
      include Dry::Monads[:try]

      # rubocop:disable Metrics/MethodLength
      def call(output: $stdout, &block)
        result = Try(&block).to_result.flatten
        return :ok if result.success?

        case result.failure
        when :quit
          output.puts 'exiting.. Goodbye'

          :ok
        when Errno::ENOENT
          output.puts 'Sorry, unable to load the provided input data'
          output.puts 'Please ensure the input data file path is correct.'
          :error
        when Errors::GenerateDatabase
          output.puts 'Sorry, there seems to be an issue in loading the application.'
          output.puts "Reason: #{result.failure.message}"
          :error
        else
          output.puts 'Oops, this is embarassing, some unexpected error has occured.'

          :error
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
