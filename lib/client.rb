class Client < HyperResource
  attr_reader :api

  def self.build(url)
    self.root = url
    self.headers = {'Accept' => 'application/hal+json', 'Content-Type' => 'application/json'}
    self.faraday(url)
    self.new
  end

  def self.faraday(url)
    @@faraday ||= Faraday.new(:url => url) do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def options
    uri = URI(URI::join(root, to_link.base_href))

    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Options.new uri
      http.request request
    end
  end
end

class Util
  def self.index_links(links)
    ready = []
    pending = []
    if links.is_a?(Hash)
      links.each do |name, obj|
        if obj.is_a?(Array)
          pending << obj
        else # safely assume HyperResource::Link. Else add edgecase above
          ready << obj.tap { |x| x.name = name }
        end
      end
    end

    index = (1..ready.size).zip(ready)
    pending.each do |list|
      start = index.size + 1; n = start + list.size - 1
      index += (start..n).zip(list)
    end
    return index.to_h
  end

  def self.index_embedded(hash)
    list = hash.to_a
    # links = list.map { |name, obj| obj.tap { |x| x.name = name } }
    (1..list.size).zip(list).to_h
  end

end


