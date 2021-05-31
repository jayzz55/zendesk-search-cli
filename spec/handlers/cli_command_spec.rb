# frozen_string_literal: true

require 'spec_helper'
require 'handlers/cli_command'
require 'dry-monads'
require 'stringio'

describe Handlers::CliCommand do
  include Dry::Monads[:result]

  let(:cli_command) do
    described_class.new(search_app: search_app, input: input, output: output)
  end
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:search_app) do
    instance_double(
      SearchApp,
      available_records: available_records,
      get_search_terms_for: get_search_terms_for,
      validate_search_term: validate_search_term,
      search_for: search_for
    )
  end
  let(:available_records) do
    Success(['users'])
  end
  let(:get_search_terms_for) do
    Success(['name'])
  end
  let(:validate_search_term) do
    Success()
  end
  let(:search_for) do
    Success([1])
  end

  describe '.call' do
    subject(:call) { cli_command.call(command_1) }

    let(:command_1) do
      lambda do |_data|
        output.puts("command_1 is called\n")
        Success({ next_command: command_2 })
      end
    end
    let(:command_2) do
      lambda do |_data|
        output.puts("command_2 is called\n")
        Success({ next_command: command_3 })
      end
    end
    let(:command_3) do
      lambda do |_data|
        output.puts("command_3 is called\n")
        Failure(:quit)
      end
    end

    it 'calls all the commands until it resolved to a Failure' do
      call
      expect(output.string).to match(
        "command_1 is called\ncommand_2 is called\ncommand_3 is called"
      )
    end

    it 'returns a failure at the end' do
      expect(call.failure).to eq(:quit)
    end
  end

  describe '.pick_record' do
    subject(:pick_record) { cli_command.pick_record(data) }

    let(:data) do
      {
        next_command: cli_command.method(:pick_record)
      }
    end
    let(:input) { StringIO.new('1') }

    it 'outputs a welcome message' do
      pick_record
      expect(output.string).to match(
        "Press '1' to search for users\nType 'quit' to quit anytime"
      )
    end

    context 'when search_app.available_records returns a Failure' do
      let(:available_records) do
        Failure('error')
      end

      it 'returns a failure' do
        expect(pick_record.failure).to eq 'error'
      end
    end

    context "when 'quit' input is received" do
      let(:input) { StringIO.new('quit') }

      it 'returns a failure' do
        expect(pick_record.failure).to eq :quit
      end
    end

    context "when entered input is valid" do
      let(:input) { StringIO.new('1') }

      it 'returns a success' do
        expect(pick_record.success?).to eq true
      end

      it 'has the record and next_command data' do
        expect(pick_record.value!).to match({
          record: 'users',
          next_command: cli_command.method('enter_search_term')
        })
      end
    end

    context "when entered input is invalid" do
      let(:input) { StringIO.new('-1') }

      it 'returns a success' do
        expect(pick_record.success?).to eq true
      end

      it 'has the next_command data' do
        expect(pick_record.value!).to match({
          next_command: cli_command.method('pick_record')
        })
      end

      it 'outputs a message' do
        pick_record
        expect(output.string).to match(
          "Sorry, don't understand -1"
        )
      end
    end
  end

  describe '.enter_search_term' do
    subject(:enter_search_term) { cli_command.enter_search_term(data) }

    let(:data) do
      {
        record: 'users'
      }
    end
    let(:input) { StringIO.new('name') }

    it 'outputs a welcome message' do
      enter_search_term
      expect(output.string).to match <<-DOCS
Search users with:
-----------------------
name
-----------------------
Enter search term:
      DOCS
    end

    context 'when search_app.get_search_terms_for returns a Failure' do
      let(:get_search_terms_for) do
        Failure('error')
      end

      it 'returns a failure' do
        expect(enter_search_term.failure).to eq 'error'
      end
    end

    context "when 'quit' input is received" do
      let(:input) { StringIO.new('quit') }

      it 'returns a failure' do
        expect(enter_search_term.failure).to eq :quit
      end
    end

    context "when entered input is valid" do
      let(:input) { StringIO.new('name') }

      it 'returns a success' do
        expect(enter_search_term.success?).to eq true
      end

      it 'has the record, search_term, and next_command data' do
        expect(enter_search_term.value!).to match({
          record: 'users',
          search_term: 'name',
          next_command: cli_command.method('enter_search_value')
        })
      end
    end

    context "when entered input is invalid" do
      let(:validate_search_term) do
        Failure(StandardError.new('invalid value'))
      end
      let(:input) { StringIO.new('-1') }

      it 'returns a success' do
        expect(enter_search_term.success?).to eq true
      end

      it 'has the next_command data' do
        expect(enter_search_term.value!).to match({
          record: 'users',
          next_command: cli_command.method('enter_search_term')
        })
      end

      it 'outputs a message' do
        enter_search_term
        expect(output.string).to match(
          "invalid value"
        )
      end
    end
  end

  describe '.enter_search_value' do
    subject(:enter_search_value) { cli_command.enter_search_value(data) }

    let(:data) do
      {
        record: 'users',
        search_term: 'name'
      }
    end
    let(:input) { StringIO.new('1') }

    it 'outputs a welcome message' do
      enter_search_value
      expect(output.string).to match(
        "Enter search value:"
      )
    end

    context "when 'quit' input is received" do
      let(:input) { StringIO.new('quit') }

      it 'returns a failure' do
        expect(enter_search_value.failure).to eq :quit
      end
    end

    context "when entered input is valid and return search results" do
      let(:search_for) { Success(['user 1']) }
      let(:input) { StringIO.new('1') }

      it 'returns a success' do
        expect(enter_search_value.success?).to eq true
      end

      it 'has the next_command data' do
        expect(enter_search_value.value!).to match({
          next_command: cli_command.method('search_again')
        })
      end

      it 'outputs a message' do
        enter_search_value
        expect(output.string).to match(
          "Found 1 search results.\nuser 1"
        )
      end
    end

    context "when entered input is valid and return no search results" do
      let(:search_for) { Success([]) }
      let(:input) { StringIO.new('1') }

      it 'returns a success' do
        expect(enter_search_value.success?).to eq true
      end

      it 'has the next_command data' do
        expect(enter_search_value.value!).to match({
          next_command: cli_command.method('search_again')
        })
      end

      it 'outputs a message' do
        enter_search_value
        expect(output.string).to match(
          "No results found."
        )
      end
    end

    context "when entered input is invalid" do
      let(:input) { StringIO.new('-1') }
      let(:search_for) { Failure(StandardError.new('invalid value')) }

      it 'returns a success' do
        expect(enter_search_value.success?).to eq true
      end

      it 'has the record, search_term and next_command data' do
        expect(enter_search_value.value!).to match({
          record: 'users',
          search_term: 'name',
          next_command: cli_command.method('enter_search_value')
        })
      end

      it 'outputs a message' do
        enter_search_value
        expect(output.string).to match(
          "invalid value"
        )
      end
    end
  end

  describe '.search_again' do
    subject(:search_again) { cli_command.search_again(data) }

    let(:data) do
      {
        next_command: cli_command.method(:search_again)
      }
    end
    let(:input) { StringIO.new('y') }

    it 'outputs a welcome message' do
      search_again
      expect(output.string).to match(
        "Search again?: y/n\n"
      )
    end

    context "when 'quit' input is received" do
      let(:input) { StringIO.new('quit') }

      it 'returns a failure' do
        expect(search_again.failure).to eq :quit
      end
    end

    context "when 'n' input is received" do
      let(:input) { StringIO.new('n') }

      it 'returns a failure' do
        expect(search_again.failure).to eq :quit
      end
    end

    context "when entered input is valid" do
      let(:input) { StringIO.new('y') }

      it 'returns a success' do
        expect(search_again.success?).to eq true
      end

      it 'has the record and next_command data' do
        expect(search_again.value!).to match({
          next_command: cli_command.method('pick_record')
        })
      end
    end

    context "when entered input is invalid" do
      let(:input) { StringIO.new('-1') }

      it 'returns a success' do
        expect(search_again.success?).to eq true
      end

      it 'has the next_command data' do
        expect(search_again.value!).to match({
          next_command: cli_command.method('search_again')
        })
      end

      it 'outputs a message' do
        search_again
        expect(output.string).to match(
          "Sorry, don't understand, please enter 'y' or 'n'\n"
        )
      end
    end
  end
end
