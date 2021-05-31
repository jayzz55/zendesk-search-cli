# frozen_string_literal: true

require 'search_app'
require 'dry/monads'
require 'dry/monads/do'
require 'handlers/with_error_handling'
require 'handlers/printer'
require 'handlers/cli_command'
require 'handlers/load_search_app'

INPUT_DATA = {
  users: 'data/users.json',
  organizations: 'data/organizations.json',
  tickets: 'data/tickets.json'
}.freeze

class Main
  class << self
    def call(input_data: INPUT_DATA, output: Handlers::Printer.new, input: $stdin)
      Handlers::WithErrorHandling.call(output: output) do
        Handlers::LoadSearchApp.call(output: output, input_data: input_data).bind do |search_app|
          Handlers::CliCommand
            .new(search_app: search_app, input: input, output: output)
            .call
        end
      end
    end
  end
end
