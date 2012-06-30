require 'rubygems'
require 'net/http'
require 'uri'

require 'json'


def execute_request (req)
  uri=URI.parse('https://api.github.com')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
  response=http.start { |http| http.request(req) }
  JSON.parse(response.body)
end


def get_gists(id)
  query=(id.nil?) ? "/gists" : "/gists/#{id}"
  req=Net::HTTP::Get.new(query, initheader = {'Content-Type' => 'application/json'})
  result=execute_request(req)
  p result
 
end

def update_gists(script,id)
 req=Net::HTTP::Patch.new(query, initheader = {'Content-Type' => 'application/json'})
req.body = {
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
end

def save_gists(app_name, script, id=nil)
  query=(id.nil?) ? "/gists" : "/gists/#{id}"
  p query
  if (id.nil?)
  req = Net::HTTP::Post.new(query, initheader = {'Content-Type' => 'application/json'})
  else
 end

  if (id.nil?)
    req.body = {
        "description" => "Template of #{app_name}",
        "public" => true,
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
  else
    
  end
  p req.body
    result=execute_request(req)
    p result
    result["id"]
  end


  #id=save_gists("asdad", "test")
 #p id
  get_gists("3023387")
  id=save_gists("asdad", "test 2", "3023387")
  p id

#uri-URI.parse('https://api.github.com/gists')
#http = Net::HTTP.new(uri.host, uri.port)


# curl -i https://api.github.com/gists -X POST -d '{"description" => "the description for this gist","public" => true,"files" => { "file1.txt" => {"content" => "String file contents"}}}'
