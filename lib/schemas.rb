# frozen_string_literal: true

USERS_SCHEMA = {
  '_id' => { 'type' => 'Integer', 'primary_key' => true },
  'url' => { 'type' => 'String' },
  'external_id' => { 'type' => 'String' },
  'name' => { 'type' => 'String' },
  'alias' => { 'type' => 'String' },
  'created_at' => { 'type' => 'Time' },
  'active' => { 'type' => 'Boolean' },
  'verified' => { 'type' => 'Boolean' },
  'shared' => { 'type' => 'Boolean' },
  'locale' => { 'type' => 'String' },
  'timezone' => { 'type' => 'String' },
  'last_login_at' => { 'type' => 'Time' },
  'email' => { 'type' => 'String' },
  'phone' => { 'type' => 'String' },
  'signature' => { 'type' => 'String' },
  'organization_id' => { 'type' => 'Integer' },
  'tags' => { 'type' => 'Array[String]' },
  'suspended' => { 'type' => 'Boolean' },
  'role' => { 'type' => 'String' }
}.freeze

TICKETS_SCHEMA = {
  '_id' => { 'type' => 'String', 'primary_key' => true },
  'url' => { 'type' => 'String' },
  'external_id' => { 'type' => 'String' },
  'created_at' => { 'type' => 'Time' },
  'type' => { 'type' => 'String' },
  'subject' => { 'type' => 'String' },
  'description' => { 'type' => 'String' },
  'priority' => { 'type' => 'String' },
  'status' => { 'type' => 'String' },
  'submitter_id' => { 'type' => 'Integer' },
  'assignee_id' => { 'type' => 'Integer' },
  'organization_id' => { 'type' => 'Integer' },
  'tags' => { 'type' => 'Array[String]' },
  'has_incidents' => { 'type' => 'Boolean' },
  'due_at' => { 'type' => 'Time' },
  'via' => { 'type' => 'String' }
}.freeze

ORGANIZATIONS_SCHEMA = {
  '_id' => { 'type' => 'Integer', 'primary_key' => true },
  'url' => { 'type' => 'String' },
  'external_id' => { 'type' => 'String' },
  'name' => { 'type' => 'String' },
  'domain_names' => { 'type' => 'Array[String]' },
  'created_at' => { 'type' => 'Time' },
  'details' => { 'type' => 'String' },
  'shared_tickets' => { 'type' => 'Boolean' },
  'tags' => { 'type' => 'Array[String]' }
}.freeze
