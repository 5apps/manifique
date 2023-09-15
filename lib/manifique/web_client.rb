require 'json'
require 'faraday'
require 'faraday/follow_redirects'
require 'nokogiri'
require 'manifique/metadata'
require 'manifique/errors'

module Manifique
  class WebClient

    def initialize(options={})
      @options = options
      @url = options[:url]
      @metadata = Metadata.new(url: @url)
    end

    def fetch_metadata
      fetch_website

      if manifest = fetch_web_manifest
        @metadata.load_from_web_manifest(manifest)
      end
      @metadata.load_from_html(@html)

      @metadata
    end

    private

    def fetch_website
      res = do_get_request @url
      @html = Nokogiri::HTML(res.body)
    rescue
      false
    end

    def fetch_web_manifest
      return false unless manifest_url = discover_web_manifest_url(@html)

      unless manifest_url.match(/^https?\:\/\//)
        # Link is just the manifest path, not an absolute URL
        manifest_url = [@url.gsub(/\/$/, ''), manifest_url.gsub(/^\//, '')].join('/')
      end

      res = do_get_request manifest_url

      JSON.parse(res.body)
    end

    def do_get_request(url)
      conn = Faraday.new do |faraday|
        faraday.response :follow_redirects
        faraday.adapter Faraday.default_adapter
      end
      res = conn.get url
      if res.status < 400
        res
      else
        raise Manifique::Error.new "Failed with HTTP status #{res.status}", "http_#{res.status}", url
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError
      raise Manifique::Error.new "Failed to connect", "connection_failed", url
    end

    def discover_web_manifest_url(html)
      html.at_css("link[rel=manifest]").attributes["href"].value
    rescue
      false
    end
  end
end
