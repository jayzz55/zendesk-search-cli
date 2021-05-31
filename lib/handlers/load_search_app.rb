# frozen_string_literal: true

require 'search_app'
require 'dry/monads'
require 'dry/monads/do'

module Handlers
  class LoadSearchApp
    class << self
      include Dry::Monads::Do.for(:call)
      include Dry::Monads[:try, :result]

      def call(output:, input_data:)
        output.puts('Loading data...')
        loaded_input_data = yield load_input_data(input_data)
        output.puts('Finished loading data!')

        output.puts('Initializing application...')
        search_app = yield SearchApp.init(
          user_json: loaded_input_data[:user_json],
          organization_json: loaded_input_data[:organization_json],
          ticket_json: loaded_input_data[:ticket_json]
        )
        output.puts('Finished initializing application!')
        output.puts('=======================================================')
        output.puts('Welcome to Zendesk Search')
        Success(search_app)
      end

      private

      def load_input_data(input_data)
        Try[Errno::ENOENT] do
          {
            user_json: File.read(input_data[:users]),
            organization_json: File.read(input_data[:organizations]),
            ticket_json: File.read(input_data[:tickets])
          }
        end.to_result
      end
    end
  end
end
