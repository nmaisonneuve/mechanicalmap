require 'fusion_tables'
require 'open-uri'

class FtDao

  include Singleton

  SERVICE_URL = "https://tables.googlelabs.com/api/query"
  MAXIMUM_INSERT=500 #maximum insert queries according to https://developers.google.com/fusiontables/docs/developers_guide

  def initialize()
    @ft=GData::Client::FusionTables.new
    @ft.clientlogin("citizencyberscience", "noisetube") # I know you know...
    @doclist=GData::Client::DocList.new(:authsub_scope => ["https://docs.google.com/feeds/"], :source => "fusiontables-v1", :version => '3.0')
    @doclist.clientlogin("citizencyberscience", "noisetube") # I know you know...
  end

  def create_table(table_name, columns)
    fields = columns.map { |col| "'#{col[:name]}': #{col[:type].upcase}" }.join(", ")
    sql = "CREATE TABLE '#{table_name}' (#{fields})"
    p sql
    sql="sql=" + CGI::escape(sql)+"&encid=true" #encrypted table id
    p SERVICE_URL
    resp = @ft.post(SERVICE_URL, sql)
    table_id = resp.body.split("\n")[1].chomp
    table_id
  end


# Connect to service
  def set_permission(resource_id, email_owner)

    #generate queries for changing permission
    acl_entry_owner = <<-EOF
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'>
  <category scheme='http://schemas.google.com/g/2005#kind'
    term='http://schemas.google.com/acl/2007#accessRule'/>
  <gAcl:role value='writer'/>
  <gAcl:scope type='user' value='#{email_owner}'/>
</entry>
    EOF

    acl_entry_visibility = <<-EOF
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:gAcl='http://schemas.google.com/acl/2007'>
<category scheme='http://schemas.google.com/g/2005#kind'
           term='http://schemas.google.com/acl/2007#accessRule'/>
<gAcl:role value='reader'/>
<gAcl:scope type="default"/>
</entry>
    EOF

    #TODO handling errors
    response = @doclist.post("https://docs.google.com/feeds/default/private/full/#{resource_id}/acl", acl_entry_owner).to_xml
    response = @doclist.post("https://docs.google.com/feeds/default/private/full/#{resource_id}/acl", acl_entry_visibility).to_xml
  end

  def enqueue(table_id, rows)
    queries=[]
    to_process=false

    rows.each_with_index { |row, i|

      queries<<"INSERT INTO #{table_id} (#{row.keys.join(",")}) VALUES (#{row.values.map { |value| "'#{value}'" }.join(",")});"

      if (i % (MAXIMUM_INSERT)==(MAXIMUM_INSERT-1))
        @ft.execute queries.join("")
        queries=[]
        to_process=false
      else
        to_process=true
      end
    }

    if (to_process)
      @ft.execute queries.join("")
    end
  end
end
