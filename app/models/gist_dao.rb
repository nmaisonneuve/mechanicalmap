require 'net/http'
require 'uri'
require 'singleton'

class GistDao

  include Singleton

 TOKEN="5d1510e4b2334c507f582c3c057005af96d24271"


def update_gists(id,script)
 query="/gists/#{id}?access_token=#{TOKEN}"
 req=Net::HTTP::Patch.new(query, initheader = {'Content-Type' => 'application/json'})
 req.body = {
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
     result=execute_request(req)
    result["id"]
end

def get_script(id)
  query="/gists/#{id}?access_token=#{TOKEN}"
  req = Net::HTTP::Get.new(query)
  result=execute_request(req)
  p result
  result["files"][0]["content"]
end

def fork_gists(id)
  query="/gists/#{id}/fork?access_token=#{TOKEN}" 
  req = Net::HTTP::Post.new(query)
  result=execute_request(req)
  result["id"]
end  

def create_gists(app_name, script)
 
  query="/gists?access_token=#{TOKEN}" 
  req = Net::HTTP::Post.new(query, initheader = {'Content-Type' => 'application/json'})
    req.body = {
        "description" => "Task Template of the app #{app_name}",
        "public" => true,
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
    result=execute_request(req)
    result["id"]
end


protected

def execute_request (req)
  uri=URI.parse('https://api.github.com')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
  response=http.start { |http| http.request(req) }
  JSON.parse(response.body)
end

end