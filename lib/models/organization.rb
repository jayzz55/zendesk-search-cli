# frozen_string_literal: true

require 'schema'

module Models
  Organization = Struct.new(
    *ORGANIZATIONS_SCHEMA.keys.map(&:to_sym),
    :associated_tickets,
    :associated_users,
    keyword_init: true
  ) do
    def with_associations(tickets:, users:)
      self.class.new(
        to_h.merge(
          associated_tickets: tickets,
          associated_users: users
        )
      )
    end
  end
end
