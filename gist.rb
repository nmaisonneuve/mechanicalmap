require 'rubygems'
require 'net/http'
require 'uri'

res = Net::HTTP.post_form(URI.parse('http://api.github.com/gists'),
                          {
                              "description" => "the description for this gist",
                              "public" => true,
                              "files" => {
                                  "file1.txt" => {
                                      "content" => "String file contents"
                                  }
                              }
                          })
puts res.body