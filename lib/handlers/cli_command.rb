# frozen_string_literal: true

require 'search_app'
require 'dry/monads'
require 'dry/monads/do'

module Handlers
  class CliCommand
    include Dry::Monads::Do.for(:pick_record, :enter_search_term, :enter_search_value)
    include Dry::Monads[:try, :result]

    attr_reader :search_app, :input, :output

    def initialize(search_app:, input:, output:)
      @search_app = search_app
      @input = input
      @output = output
    end

    def call(next_command = method('pick_record'))
      result = Success({ next_command: next_command })

      while result.success?
        data = result.value!
        next_command = data[:next_command]
        result = next_command.call(data)
      end

      result
    end

    def pick_record(data)
      mappings = yield generate_record_mappings
      output.puts("Type 'quit' to quit anytime")

      case input.gets.chomp
        in 'quit'
          Failure(:quit)
        in value if mappings[value.to_i]
          record = mappings[value.to_i]
          Success({ record: record, next_command: method('enter_search_term') })
        in _ => keyed_input
          output.puts "Sorry, don't understand #{keyed_input}"
          Success(data)
      end
    end

    def enter_search_term(data)
      record = data[:record]
      search_terms = yield search_app.get_search_terms_for(record: record)
      print_enter_search_term_instruction(record, search_terms)

      case input.gets.chomp
        in 'quit'
          Failure(:quit)
        in _ => search_term
          handle_search_term(record, search_term)
      end
    end

    def enter_search_value(data)
      output.puts 'Enter search value:'

      case input.gets.chomp
        in 'quit'
          Failure(:quit)
        in _ => value
          record, search_term = data.values_at(:record, :search_term)
          handle_search_value(record, search_term, value)
      end
    end

    def search_again(data)
      output.puts 'Search again?: y/n'

      case input.gets.chomp
        in 'quit' | 'n'
          Failure(:quit)
        in 'y'
          Success({ next_command: method('pick_record') })
        in _ => search_value
          output.puts "Sorry, don't understand, please enter 'y' or 'n'"

          Success(data)
      end
    end

    private

    def generate_record_mappings
      search_app.available_records.fmap do |records|
        mappings = {}

        records.each_with_index do |record, index|
          output.puts "Press '#{index + 1}' to search for #{record}"
          mappings[index + 1] = record
        end

        mappings
      end
    end

    def print_enter_search_term_instruction(record, search_terms)
      output.puts "Search #{record} with:"
      output.puts '-----------------------'
      output.puts search_terms
      output.puts '-----------------------'
      output.puts 'Enter search term:'
    end

    def handle_search_term(record, search_term)
      search_app
        .validate_search_term(record: record, search_term: search_term)
        .fmap { { record: record, search_term: search_term, next_command: method('enter_search_value') } }
        .or do |failure|
          output.puts failure.message
          Success({ record: record, next_command: method('enter_search_term') })
        end
    end

    def handle_search_value(record, search_term, value)
      search_app
        .search_for(record: record, search_term: search_term, value: value)
        .fmap { |results| print_search_results(results) }
        .fmap { { next_command: method('search_again') } }
        .or do |failure|
          output.puts failure.message
          Success({ record: record, search_term: search_term, next_command: method('enter_search_value') })
        end
    end

    def print_search_results(results)
      if results.empty?
        output.puts 'No results found.'
      else
        output.puts "Found #{results.size} search results."
        output.puts results
      end
    end
  end
end
