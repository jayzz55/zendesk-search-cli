# frozen_string_literal: true

module Representers
  class Ticket
    class << self
      def call(ticket)
        string = ''
        string += "* Ticket with _id #{ticket._id}\n"
        string += represent_ticket_data(ticket)

        string += "--- Submitter:\n"
        string += represent_user(ticket.associated_submitter)

        string += "--- Assignee:\n"
        string += represent_user(ticket.associated_assignee)

        string += "--- Organization:\n"
        string += represent_organization(ticket.associated_organization)

        string
      end

      private

      def represent_ticket_data(ticket)
        string = ''
        value_mappings = TICKETS_SCHEMA.keys.map { |attr| [attr, ticket[attr.to_sym]] }

        value_mappings.each { |(attr, value)| string += "#{attr.ljust(30)} #{value}\n" }

        string
      end

      def represent_user(user)
        return '' if user.nil?

        string = ''
        string += ''.rjust(3) + ' name:'.ljust(10) + " #{user[:name]}\n"
        string += ''.rjust(3) + ' alias:'.ljust(10) + " #{user[:alias]}\n"
        string += ''.rjust(3) + ' role:'.ljust(10) + " #{user[:role]}\n"
        string
      end

      def represent_organization(organization)
        return '' if organization.nil?

        ''.rjust(3) + ' name:'.ljust(10) + " #{organization[:name]}\n"
      end
    end
  end
end
