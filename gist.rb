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
end

def update_gists(script,id)
  token="5d1510e4b2334c507f582c3c057005af96d24271"
 query="/gists/#{id}?access_token=#{token}"
 req=Net::HTTP::Patch.new(query, initheader = {'Content-Type' => 'application/json'})
 req.body = {
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
     result=execute_request(req)
    p result
end

def save_gists(app_name, script)
  token="5d1510e4b2334c507f582c3c057005af96d24271"
  query="/gists?access_token=#{token}" 
  p query
  req = Net::HTTP::Post.new(query, initheader = {'Content-Type' => 'application/json'})
    req.body = {
        "description" => "Template of #{app_name}",
        "public" => true,
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
  #p req.body
    result=execute_request(req)
   # p result
    p result["id"]
  end


  id=save_gists("asdad", "test")
  #get_gists(id)
  id=update_gists("asdad", "3027544")
 
#uri-URI.parse('https://api.github.com/gists')
#http = Net::HTTP.new(uri.host, uri.port)


# curl -i https://api.github.com/gists -X POST -d '{"description" => "the description for this gist","public" => true,"files" => { "file1.txt" => {"content" => "String file contents"}}}'
#curl -u citizentasks -d  '{"scopes":["gist"], "note": "admin script" }' -i https://api.github.com/authorizations 
