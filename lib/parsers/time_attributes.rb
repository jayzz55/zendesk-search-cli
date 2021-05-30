# frozen_string_literal: true

require 'dry/monads'
require 'time'

module Parsers
  class TimeAttributes
    class << self
      include Dry::Monads[:maybe, :try]

      def call(value:)
        Try[ArgumentError] { Time.parse(value).utc }
          .to_maybe
          .maybe do |time|
            [time.year, time.month, time.day, time.hour, time.min, time.sec]
          end
      end
    end
  end
end
