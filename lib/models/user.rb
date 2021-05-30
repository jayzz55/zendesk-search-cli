# frozen_string_literal: true

require 'schema'

module Models
  User = Struct.new(
    *USERS_SCHEMA.keys.map(&:to_sym),
    :associated_submitted_tickets,
    :associated_assigned_tickets,
    :associated_organization,
    keyword_init: true
  ) do
    def with_associations(submitted_tickets:, assigned_tickets:, organization:)
      self.class.new(
        to_h.merge(
          associated_submitted_tickets: submitted_tickets,
          associated_assigned_tickets: assigned_tickets,
          associated_organization: organization
        )
      )
    end
  end
end
