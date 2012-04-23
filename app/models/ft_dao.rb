require 'fusion_tables'
require 'open-uri'

class FtDao

  include Singleton

  SERVICE_URL = "https://tables.googlelabs.com/api/query"
  MAXIMUM_INSERT=499 #maximum insert queries according to https://developers.google.com/fusiontables/docs/developers_guide

  def initialize()
    @ft=GData::Client::FusionTables.new
    @ft.clientlogin("citizencyberscience", "noisetube") # I know you know...
    @doclist=GData::Client::DocList.new(:authsub_scope => ["https://docs.google.com/feeds/"], :source => "fusiontables-v1", :version => '3.0')
    @doclist.clientlogin("citizencyberscience", "noisetube") # I know you know...
  end

  def create_table(table_name, columns)
    fields = columns.map { |col| "'#{col["name"]}': #{col["type"].upcase}" }.join(", ")
    sql = "CREATE TABLE '#{table_name}' (#{fields})"
    sql="sql=" + CGI::escape(sql)+"&encid=true" #encrypted table id
    resp = @ft.post(SERVICE_URL, sql)
    table_id = resp.body.split("\n")[1].chomp
    table_id
  end


# Connect to service
  def change_ownership(table_id, email_owner)

    role= (email_owner[/@gmail/].nil?)? "writer" : "owner"
    #generate queries for changing permission
    acl_entry_owner = <<-EOF
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'>
  <category scheme='http://schemas.google.com/g/2005#kind'
    term='http://schemas.google.com/acl/2007#accessRule'/>
  <gAcl:role value='#{role}'/>
  <gAcl:scope type='user' value='#{email_owner}'/>
</entry>
    EOF
    response = @doclist.post("https://docs.google.com/feeds/default/private/full/#{table_id}/acl", acl_entry_owner).to_xml
  end

  def set_exportable(table_id)
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
    response = @doclist.post("https://docs.google.com/feeds/default/private/full/#{table_id}/acl", acl_entry_visibility).to_xml
  end

  def import(table_id, limit=10)
    tasks_ids=@ft.execute "SELECT task_id FROM #{table_id} LIMIT #{limit}"
    tasks_ids.each { |task|
      yield(task[:task_id].to_i)
    }
  end

  def sync_answers(answers)

    i=0
    queries=[]
    to_process=false
    answers_to_process=[]
    answers.each { |answer|

      table_id=answer.task.app.output_ft

      #correct bugs if string not decoded
      if (answer.answer.is_a? String)
        answer.answer= ActiveSupport::JSON.decode(answer.answer)
        answer.save
      end

      if (answer.answer.is_a? Array)
        answer.answer.each { |row|

          queries<<"INSERT INTO #{table_id} (#{row.keys.join(",")}) VALUES (#{row.values.map { |value| "'#{value}'" }.join(",")});"
          #we're batching
          if ((i>0) && (i % (MAXIMUM_INSERT)==0))
            @ft.execute queries.join("")
            queries=[]

            # We can now update their states
            answers_to_process.each { |answer_processed|
              answer_processed.ft_sync=true
              answer_processed.save
            }
            answers_to_process=[]

            to_process=false
          else
            to_process=true
          end
          i=i+1
        }
        answers_to_process<<answer
      else
        raise Exception.new("answer not handled :#{answer.answer}")
      end
    }

    if (to_process)
      @ft.execute queries.join("")
      # We can now update their states
      answers_to_process.each { |answer|
        answer.ft_sync=true
        answer.save
      }
    end

  end

  def enqueue(table_id, rows)
    queries=[]
    to_process=false
    rows.each_with_index { |row, i|
      queries<<"INSERT INTO #{table_id} (#{row.keys.join(",")}) VALUES (#{row.values.map { |value| "'#{value}'" }.join(",")});"
      #we're batching
      if ((i>0) && (i % (MAXIMUM_INSERT)==0))
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
