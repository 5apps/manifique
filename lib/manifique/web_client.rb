require 'faraday'
require 'faraday_middleware'
require "nokogiri"
require 'nitlink/response'

module Manifique
  class WebClient
    def initialize(options)
      @options = options
      @url = options[:url]
    end

    def fetch_web_manifest
      conn = Faraday.new do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end
      res = conn.get @url
      raise res.inspect
    end
  end
end
