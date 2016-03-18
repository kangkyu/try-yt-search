require "net/http"
require "uri"
require 'json'
require_relative 'custom_methods'

module TryYt
  class Request
    def initialize(attrs = {})
      # host, query, path, method, access_token, etc
      @host = "www.googleapis.com"
      @path = "/youtube/v3/search"
      @query_hash = {
        part: "snippet",
        # channel_id: "UCPCk_8dtVyR1lLHMBEILW4g",
        q: "penguin",
        key: ENV["YT_API_KEY"],
        max_results: "10",
        order: "date",
        type: "video"
      }
    end

    def run
      response = Net::HTTP.get_response(uri)
      JSON response.body
    end

    def as_curl
      curl = ['curl']
      curl << "-X #{http_request.method}"
      http_request.each_header do |name, value|
        curl << %Q{-H "#{name}: #{value}"}
      end
      curl << %Q{-d '#{http_request.body}'} if http_request.body
      curl << %Q{"#{uri.to_s}"}
      curl.join(' ')
    end

    def http_request
      @http_request ||= Net::HTTP::Get.new(uri)
    end

  private
    def uri
      @uri ||= URI::HTTPS.build(host: @host, path: @path, query: @query_hash.to_query)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  print TryYt::Request.new.as_curl + "\n"
end
