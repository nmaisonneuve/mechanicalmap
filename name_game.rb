require 'rubygems'

require 'fusion_tables'
require 'open-uri'
require 'singleton'

SERVICE_URL = "https://tables.googlelabs.com/api/query"
MAXIMUM_INSERT=499

def enqueue(table_id, rows)
  queries=[]
  to_process=false
  rows.each_with_index { |row, i|
    queries<<"INSERT INTO #{table_id} (#{row.keys.join(",")}) VALUES (#{row.values.map { |value| "'#{value}'" }.join(",")});"
    #we're batching
    if ((i>0) && (i % (MAXIMUM_INSERT)==0))
      $ft.execute queries.join("")
      queries=[]
      to_process=false
    else
      to_process=true
    end
  }

  if (to_process)
    $ft.execute queries.join("")
  end
end


TaskGFTable_id="4371217"

rows=[]
puts "Requesting data from FT"
$ft=GData::Client::FusionTables.new
$ft.clientlogin("citizencyberscience", "noisetube") # I know you know...
sql = "SELECT ClusterID,Count()  FROM 3950961 where ClusterState=-1 group by ClusterID LIMIT 1000"

sql="sql=" + CGI::escape(sql) #encrypted table id
resp = $ft.post(SERVICE_URL, sql)

idx=1


puts "Transforming data"
resp.body.split("\n").each { |row|
  cells=row.split(",")
  if (!!(cells[0] =~ /^[-+]?[0-9]+$/))
    rows<<{"task_id" => idx, "clusterID" => cells[0], "freq" => cells[1].to_i}
    idx=idx+1
  end
}

puts "Reindexing task by freq"
idx=1
rows=rows.sort{ |a,b| a["freq"]<=>b["freq"]}
rows.each { |row|
    row["task_id"]=idx
    idx=idx+1
}

puts "Storing data into FT"
enqueue(TaskGFTable_id, rows)


