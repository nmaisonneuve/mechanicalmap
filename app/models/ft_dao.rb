require 'fusion_tables'
require 'open-uri'
SERVICE_URL = "https://tables.googlelabs.com/api/query"

class FtDao

  include Singleton

  def initialize()
    @ft=GData::Client::FusionTables.new
    @ft.clientlogin("citizencyberscience", "noisetube")  # I know you know...
    @doclist=GData::Client::DocList.new(:authsub_scope => ["https://docs.google.com/feeds/"], :source => "fusiontables-v1", :version => '3.0')
    @doclist.clientlogin("citizencyberscience", "noisetube")  # I know you know...
  end

  def create_table(table_name, columns)
    fields = columns.map { |col| "'#{col["name"]}': #{col["type"].upcase}" }.join(", ")
    sql = "CREATE TABLE '#{table_name}' (#{fields})"
    sql="sql=" + CGI::escape(sql)+"&encid=true" #encrypted table id # create table
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
    rows.each { |row|
      queries<<"INSERT INTO #{table_id} (#{row.keys.join(",")}) VALUES (#{row.values.map{|value| "'#{value}'"}.join(",")});"
    }
    queries=queries.join("")
    @ft.execute queries

  end
end
