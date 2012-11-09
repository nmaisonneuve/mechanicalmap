require 'fusion_tables'
require 'open-uri'
require 'singleton'

class FtDao

  include Singleton

  SERVICE_URL = "https://tables.googlelabs.com/api/query"
  TABLE_BASE_URL = "https://www.google.com/fusiontables/DataSource?docid="

  MAXIMUM_INSERT=499 #maximum insert queries according to https://developers.google.com/fusiontables/docs/developers_guide

  ANSWERS_SCHEMA = [
    {"name" => "answer_id", "type" => "number"},
    {"name" => "task_id", "type" => "number"},
    {"name" => "user_id", "type" => "string"},
    {"name" => "created_at", "type" => "datetime"},
    {"name" => "content", "type" => "string"}]


  CHALLENGES_SCHEMA = [
    {"name" => "task_id", "type" => "number"},
    {"name" => "input", "type" => "string"}]

  def self.create_answers_table(owner_email)
    FtDao.instance.create_table_for_owner("Answers Table", ANSWERS_SCHEMA, owner_email)
  end

  def self.create_challenges_table(owner_email)
    FtDao.instance.create_table_for_owner("Tasks Table", CHALLENGES_SCHEMA, owner_email)
  end

  def self.clone_table(table_id, table_name, owner_email)
    schema = FtDao.instance.get_schema(table_id)
    FtDao.instance.create_table_for_owner(table_name, schema, owner_email)
  end


  def initialize()
    @ft = GData::Client::FusionTables.new
    @ft.clientlogin("citizencyberscience", "noisetube") # I know you know...
    @doclist = GData::Client::DocList.new(:authsub_scope => ["https://docs.google.com/feeds/"], :source => "fusiontables-v1", :version => '3.0')
    @doclist.clientlogin("citizencyberscience", "noisetube") # I know you know...
  end

  def create_table(table_name, columns)
    fields = columns.map { |col| "'#{col["name"]}': #{col["type"].upcase}" }.join(", ")
    sql = "CREATE TABLE '#{table_name}' (#{fields})"
    sql="sql=" + CGI::escape(sql)+"&encid=true" #encrypted table id
    resp = @ft.post(SERVICE_URL, sql)
    table_id = resp.body.split("\n")[1].chomp
  end

  def create_table_for_owner(table_name, columns,user_email)
    table_id = create_table(table_name, columns)
    set_exportable(table_id)  # set permission exportable
    change_ownership(table_id, user_email) unless user_email.blank?
    table_id
  end

  def delete_all(table_name)
    sql="sql=" + CGI::escape("DELETE FROM #{table_name}")
    resp=@ft.post(SERVICE_URL, sql)
  end

  def get_schema(table_id)
    sql = "sql= " + CGI::escape("DESCRIBE #{table_id}")
    resp = @ft.post(SERVICE_URL, sql)
    resp.body.split("\n")[1..-1].map do |col|
      col = col.split(",")
      {"name" => col[1], "type" => col[2]}
    end
  end

  # Connect to service
  def change_ownership(table_id, email_owner)
    role = (email_owner[/@gmail/].nil?) ? "writer" : "owner"
    #generate queries for changing permission
    acl_entry_owner = <<-EOF
    <entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'><category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/acl/2007#accessRule'/> <gAcl:role value='#{role}'/> <gAcl:scope type='user' value='#{email_owner}'/></entry>
    EOF
    response = @doclist.post("https://docs.google.com/feeds/default/private/full/#{table_id}/acl", acl_entry_owner).to_xml
  end

  def set_exportable(table_id)
    acl_entry_visibility = <<-EOF
    <entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'> <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/acl/2007#accessRule'/><gAcl:role value='reader'/> <gAcl:scope type="default"/> </entry>
    EOF

    response = @doclist.post("https://docs.google.com/feeds/default/private/full/#{table_id}/acl", acl_entry_visibility).to_xml
  end



  def import(table_id, task_column)
    tasks_ids=@ft.execute "SELECT #{task_column}, count() FROM #{table_id} group by #{task_column} "
    puts " #{tasks_ids.size} tasks to index"
    tasks_ids.each { |task|
      yield(task[task_column.to_sym])
    }
  end

  def sync_answers(answers)

    return if answers.empty?

    i=0
    queries=[]
    to_process=false
    answers_to_process=[]
    answers.each { |answer|
      if Answer.where("answers.id = ?",answer.id).where(:ft_sync => false).empty?
        next
      end

      table_id=answer.task.app.output_ft
      begin
        answer_rows=ActiveSupport::JSON.decode(answer.answer)
      rescue
        answer_rows=YAML::load(answer.answer)
      end

      if (answer_rows.is_a? Array)
        begin
          answer_rows.each { |row|

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
        rescue Exception => e
          raise Exception.new("FTDAO: #{e.message}\n#{answer.answer}")
        end
      else
        answer.ft_sync=true
        answer.save
        raise Exception.new("answer not handled :#{answer_rows}")
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
