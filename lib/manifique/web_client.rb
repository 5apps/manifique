require 'faraday'
require 'faraday_middleware'
require "nokogiri"
require 'nitlink/response'

require 'pry'

module Manifique
  class WebClient
    def initialize(options)
      @options = options
      @url = options[:url]
    end

    def fetch_web_manifest
      do_get_request @url
      # binding.pry
    end

    private

    def do_get_request(url)
      conn = Faraday.new do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end
      res = conn.get url
      if res.status > 400
        raise "Could not fetch #{url} successfully (#{res.status})"
      end
    end
  end
end
