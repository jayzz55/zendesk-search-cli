# frozen_string_literal: true

require 'spec_helper'
require 'main'
require 'stringio'

describe Main do
  subject(:main) { Main.call(output: printer, input: input) }

  let(:input) { StringIO.new(input_commands.join("\n")) }
  let(:output) { StringIO.new }
  let(:printer) { Handlers::Printer.new(output)}

  context 'searching for users' do
    context 'when there are users to be found' do
      let(:input_commands) { ['1', '_id', '1', 'n'] }

      it 'displays the search results' do
        main
        expect(output.string).to match <<-DOCS
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
=======================================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'quit' to quit anytime
Search users with:
-----------------------
_id
url
external_id
name
alias
created_at
active
verified
shared
locale
timezone
last_login_at
email
phone
signature
organization_id
tags
suspended
role
-----------------------
Enter search term:
Enter search value:
Found 1 search results.
* User with _id 1
_id                            1
url                            http://initech.zendesk.com/api/v2/users/1.json
external_id                    74341f74-9c79-49d5-9611-87ef9b6eb75f
name                           Francisca Rasmussen
alias                          Miss Coffey
created_at                     2016-04-15T05:19:46 -10:00
active                         true
verified                       true
shared                         false
locale                         en-AU
timezone                       Sri Lanka
last_login_at                  2013-08-04T01:03:27 -10:00
email                          coffeyrasmussen@flotonic.com
phone                          8335-422-718
signature                      Don't Worry Be Happy!
organization_id                119
tags                           ["Springville", "Sutton", "Hartsville/Hartley", "Diaperville"]
suspended                      true
role                           admin
--- Submitted tickets:
 1. subject:  A Nuisance in Kiribati
    priority: high
    status:   open
 2. subject:  A Nuisance in Saint Lucia
    priority: urgent
    status:   pending
--- Assigned Tickets:
 1. subject:  A Problem in Russian Federation
    priority: low
    status:   solved
 2. subject:  A Problem in Malawi
    priority: urgent
    status:   solved
--- Organization:
    name:     Multron
Search again?: y/n
exiting.. Goodbye
        DOCS
      end
    end

    context 'when there are no users to be found' do
      let(:input_commands) { ['1', '_id', '999', 'n'] }

      it 'displays the search results' do
        main
        expect(output.string).to match <<-DOCS
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
=======================================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'quit' to quit anytime
Search users with:
-----------------------
_id
url
external_id
name
alias
created_at
active
verified
shared
locale
timezone
last_login_at
email
phone
signature
organization_id
tags
suspended
role
-----------------------
Enter search term:
Enter search value:
No results found.
        DOCS
      end
    end
  end

  context 'searching for organizations' do
    context 'when there are organizations to be found' do
      let(:input_commands) { ['2', 'created_at', '2016-05-21T11:10:28 -10:00', 'n'] }

      it 'displays the search results' do
        main
        expect(output.string).to match <<-DOCS
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
=======================================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'quit' to quit anytime
Search organizations with:
-----------------------
_id
url
external_id
name
domain_names
created_at
details
shared_tickets
tags
-----------------------
Enter search term:
Enter search value:
Found 1 search results.
* Organization with _id 101
_id                            101
url                            http://initech.zendesk.com/api/v2/organizations/101.json
external_id                    9270ed79-35eb-4a38-a46f-35725197ea8d
name                           Enthaze
domain_names                   ["kage.com", "ecratic.com", "endipin.com", "zentix.com"]
created_at                     2016-05-21T11:10:28 -10:00
details                        MegaCorp
shared_tickets                 false
tags                           ["Fulton", "West", "Rodriguez", "Farley"]
--- Users:
 1. name:     Loraine Pittman
    alias:    Mr Ola
    role:     admin
 2. name:     Francis Bailey
    alias:    Miss Singleton
    role:     agent
 3. name:     Haley Farmer
    alias:    Miss Lizzie
    role:     agent
 4. name:     Herrera Norman
    alias:    Mr Vance
    role:     end-user
--- Tickets:
 1. subject:  A Drama in Portugal
    priority: low
    status:   hold
 2. subject:  A Problem in Ethiopia
    priority: low
    status:   hold
 3. subject:  A Problem in Turks and Caicos Islands
    priority: low
    status:   pending
 4. subject:  A Problem in Guyana
    priority: normal
    status:   closed
Search again?: y/n
exiting.. Goodbye
        DOCS
      end
    end

    context 'when there are no organizations to be found' do
      let(:input_commands) { ['2', '_id', '0', 'n'] }

      it 'displays the search results' do
        main
        expect(output.string).to match <<-DOCS
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
=======================================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'quit' to quit anytime
Search organizations with:
-----------------------
_id
url
external_id
name
domain_names
created_at
details
shared_tickets
tags
-----------------------
Enter search term:
Enter search value:
No results found.
Search again?: y/n
exiting.. Goodbye
        DOCS
      end
    end
  end

  context 'searching for tickets' do
    context 'when there are tickets to be found' do
      let(:input_commands) { ['3', 'subject', 'A Problem in Morocco', 'n'] }

      it 'displays the search results' do
        main
        expect(output.string).to match <<-DOCS
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
=======================================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'quit' to quit anytime
Search tickets with:
-----------------------
_id
url
external_id
created_at
type
subject
description
priority
status
submitter_id
assignee_id
organization_id
tags
has_incidents
due_at
via
-----------------------
Enter search term:
Enter search value:
Found 1 search results.
* Ticket with _id 87db32c5-76a3-4069-954c-7d59c6c21de0
_id                            87db32c5-76a3-4069-954c-7d59c6c21de0
url                            http://initech.zendesk.com/api/v2/tickets/87db32c5-76a3-4069-954c-7d59c6c21de0.json
external_id                    1c61056c-a5ad-478a-9fd6-38889c3cd728
created_at                     2016-07-06T11:16:50 -10:00
type                           problem
subject                        A Problem in Morocco
description                    Sit culpa non magna anim. Ea velit qui nostrud eiusmod laboris dolor adipisicing quis deserunt elit amet.
priority                       urgent
status                         solved
submitter_id                   14
assignee_id                    7
organization_id                118
tags                           ["Texas", "Nevada", "Oregon", "Arizona"]
has_incidents                  true
due_at                         2016-08-19T07:40:17 -10:00
via                            voice
--- Submitter:
    name:     Shepherd Joseph
    alias:    Miss Martina
    role:     admin
--- Assignee:
    name:     Lou Schmidt
    alias:    Miss Shannon
    role:     admin
--- Organization:
    name:     Limozen
Search again?: y/n
exiting.. Goodbye
        DOCS
      end
    end

    context 'when there are no tickets to be found' do
      let(:input_commands) { ['3', 'subject', 'unknown subject', 'n'] }

      it 'displays the search results' do
        main
        expect(output.string).to match <<-DOCS
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
=======================================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'quit' to quit anytime
Search tickets with:
-----------------------
_id
url
external_id
created_at
type
subject
description
priority
status
submitter_id
assignee_id
organization_id
tags
has_incidents
due_at
via
-----------------------
Enter search term:
Enter search value:
No results found.
Search again?: y/n
exiting.. Goodbye
        DOCS
      end
    end
  end
end
