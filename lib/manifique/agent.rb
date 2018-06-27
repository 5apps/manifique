require 'uri'
require "manifique/web_client"

module Manifique
  class Agent
    def initialize(options={})
      @options = options

      if url_valid?(options[:url])
        @url = options[:url]
      else
        raise "No valid URL specified"
      end
    end

    def fetch_metadata
      web_client = WebClient.new(url: @url)
      web_client.fetch_web_manifest
    end

    private

    def url_valid?(str)
      return false unless str.class == String
      url = URI.parse(str)
      url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
  end
end
