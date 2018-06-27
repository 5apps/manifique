require 'faraday'
require "nokogiri"
require 'nitlink/response'

module Manifique
  class WebClient
    def initialize(options)
      @options = options
      @url = options[:url]
    end

    def fetch_web_manifest
      @url
    end
  end
end
