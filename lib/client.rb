WUNDERLIST_URL = 'http://localhost:3000'

class Client < HyperResource
  attr_reader :api

  self.root = WUNDERLIST_URL
  self.headers = {'Accept' => 'application/hal+json', 'Content-Type' => 'application/json'}

  def self.faraday
    @@faraday ||= Faraday.new(:url => WUNDERLIST_URL) do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def options
    uri = URI(to_link.base_href)

    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Options.new uri
      http.request request
    end
  end
end

class Util
  def self.index_links(response)
    list = response.links.to_a
    links = list.map { |name, obj| obj.tap { |x| x.name = name } }
    (1..list.size).zip(links).to_h
  end

end


