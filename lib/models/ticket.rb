# frozen_string_literal: true

require 'schema'
require 'representers/ticket'

module Models
  Ticket = Struct.new(
    *TICKETS_SCHEMA.keys.map(&:to_sym),
    :associated_submitter,
    :associated_assignee,
    :associated_organization,
    keyword_init: true
  ) do
    def with_associations(submitter:, assignee:, organization:)
      self.class.new(
        to_h.merge(
          associated_submitter: submitter,
          associated_assignee: assignee,
          associated_organization: organization
        )
      )
    end

    def to_s(representer = Representers::Ticket)
      representer.call(self)
    end
  end
end
