require "manifique/web_client"

module Manifique
  class Agent
    def initialize(options)
      @options = options
      @url = options[:url]
    end

    def fetch_metadata
      web_client = WebClient.new(url: @url)
      web_client.fetch_web_manifest
    end
  end
end
