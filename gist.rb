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


def save_gists(app_name, script, id=nil)
  query=(id.nil?) ? "/gists" : "/gists/#{id}"
  p query
  req = Net::HTTP::Post.new(query, initheader = {'Content-Type' => 'application/json'})

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
    req.body = {
        "files" => {
            "template_task.html" => {
                "content" => script
            }
        }
    }.to_json
  end
  p req.body
    result=execute_request(req)
    p result
    result["id"]
  end


  id=save_gists("asdad", "test")
  p id
  id=save_gists("asdad", "test 2", id)
  p id

#uri-URI.parse('https://api.github.com/gists')
#http = Net::HTTP.new(uri.host, uri.port)


# curl -i https://api.github.com/gists -X POST -d '{"description" => "the description for this gist","public" => true,"files" => { "file1.txt" => {"content" => "String file contents"}}}'
