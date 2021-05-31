# frozen_string_literal: true

module Representers
  class User
    class << self
      def call(user)
        string = ''
        string += "* User with _id #{user._id}\n"
        string += represent_user_data(user)

        string += "--- Submitted tickets:\n"
        string += represent_tickets(user.associated_submitted_tickets)

        string += "--- Assigned Tickets:\n"
        string += represent_tickets(user.associated_assigned_tickets)

        string += "--- Organization:\n"
        string += represent_organization(user.associated_organization)

        string
      end

      private

      def represent_user_data(user)
        string = ''
        value_mappings = USERS_SCHEMA.keys.map { |attr| [attr, user[attr.to_sym]] }

        value_mappings.each { |(attr, value)| string += "#{attr.ljust(30)} #{value}\n" }

        string
      end

      # rubocop:disable Metrics/AbcSize
      def represent_tickets(tickets)
        string = ''
        tickets.each_with_index do |ticket, index|
          string += "#{index + 1}.".rjust(3) + ' subject:'.ljust(10) + " #{ticket[:subject]}\n"
          string += ''.rjust(3) + ' priority:'.ljust(10) + " #{ticket[:priority]}\n"
          string += ''.rjust(3) + ' status:'.ljust(10) + " #{ticket[:status]}\n"
        end
        string
      end
      # rubocop:enable Metrics/AbcSize

      def represent_organization(organization)
        ''.rjust(3) + ' name:'.ljust(10) + " #{organization[:name]}\n"
      end
    end
  end
end
