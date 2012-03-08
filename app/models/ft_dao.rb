require 'fusion_tables'


class FtDao

include Singleton

def initialize()
@ft=GData::Client::FusionTables.new
@ft.clientlogin("citizencyberscience","noisetube")	
end

def create_table(name, cols)
	@ft.create_table name , cols
end

def enqueue(table_id, cols, data)

@ft.execute "INSERT INTO #{table_id} (#{cols.joins(",")}) VALUES (#{data.joins(",")})"

end
end
