# http://ruby-doc.org/stdlib-2.3.0/libdoc/uri/rdoc/URI/Generic.html#method-i-userinfo-3D
# http://ruby-doc.org/stdlib-2.3.0/libdoc/net/http/rdoc/Net/HTTP.html

require "net/http"
require "uri"

host = "www.googleapis.com"
path = "/youtube/v3/search"
query_hash = {
  part: "snippet",
  # channel_id: "UCPCk_8dtVyR1lLHMBEILW4g",
  q: "penguin",
  key: ENV["YT_API_KEY"],
  max_results: "10",
  order: "date",
  type: "video"
}

class Hash
  def to_query
    to_h.map do |key, value|
      key.query_itemize + "=" + value.to_s
    end.join("&")
  end
end

class Symbol
  def query_itemize
    abc = to_s.split('_')
    abc.shift.downcase + abc.map(&:capitalize).join
  end
end

# URI::HTTP.build
# userinfo, host, port, path, query and fragment
uri = URI::HTTPS.build(host: host, path: path, query: query_hash.to_query)
response = Net::HTTP.get_response(uri)

video_ids = []
videos = {}

require 'json'

JSON.parse(response.body)["items"].each do |video|
  id = video["id"]["videoId"]
  videos[id] ||= {}
  videos[id]["title"] = video["snippet"]["title"]

  video_ids << video["id"]["videoId"]
end

path = "/youtube/v3/videos"
query_hash = {
  part: "statistics",
  id: video_ids.join(","),
  key: ENV["YT_API_KEY"],
  order: "date",
  type: "video"
}

uri = URI::HTTPS.build(host: host, path: path, query: query_hash.to_query)
response = Net::HTTP.get_response(uri)

JSON.parse(response.body)["items"].each do |video|
  id = video["id"]
  videos[id] ||= {}
  videos[id]["view_count"] = video["statistics"]["viewCount"]
end

p videos

