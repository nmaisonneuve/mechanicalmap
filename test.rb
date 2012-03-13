


#
#acl_entry = <<-EOF
#<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'>
#  <category scheme='http://schemas.google.com/g/2005#kind'
#    term='http://schemas.google.com/acl/2007#accessRule'/>
#  <gAcl:role value='writer'/>
#  <gAcl:scope type='user' value='new_writer@example.com'/>
#</entry>
#EOF
#
#GET https://docs.google.com/feeds/default/private/full/resource_id/acl
#
#POST https://docs.google.com/feeds/default/private/full/resource_id/acl
#Authorization: <your authorization header here>
#
#<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'>
#  <category scheme='http://schemas.google.com/g/2005#kind'
#    term='http://schemas.google.com/acl/2007#accessRule'/>
#  <gAcl:role value='writer'/>
#  <gAcl:scope type='user' value='new_writer@example.com'/>
#</entry>
#
#<gAcl:scope type="default"/>
#
#    POST https://docs.google.com/feeds/default/private/full/folder%3Acollection_id/acl
#Authorization: <your authorization header here>
#
#<entry xmlns="http://www.w3.org/2005/Atom"
#       xmlns:gAcl='http://schemas.google.com/acl/2007'>
#<category scheme='http://schemas.google.com/g/2005#kind'
#           term='http://schemas.google.com/acl/2007#accessRule'/>
#<gAcl:role value='reader'/>
#<gAcl:scope type='domain' value='example.com'/>
#</entry>
#
#@ft = GData::Client::FusionTables.new
#@ft.clientlogin(username, password)
#
#
#new_permissions = [("an.email@gmail.com","user","reader")]
#docsListHelper.setPermissions("New Table", new_permissions)
#
## Creating a table
#cols = [{:name => "friend name",    :type => 'string' },
#        {:name => "age",            :type => 'number' },
#        {:name => "meeting time",   :type => 'datetime' },
#        {:name => "where",          :type => 'location' }]
#
#new_table = @ft.create_table "My upcoming meetings", cols

