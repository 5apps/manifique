require 'ostruct'
require 'faraday'
require 'faraday_middleware'
require "nokogiri"
require 'manifique/metadata'
require 'pry'

module Manifique
  class WebClient

    def initialize(options={})
      @options = options
      @url = options[:url]
      @metadata = Metadata.new
    end

    def fetch_metadata
      fetch_website
      manifest = fetch_web_manifest

      if @metadata.manifest = manifest
        return @metadata
      else
        #TODO assemble from HTML elements
      end

      @metadata
    end

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

      JSON.parse(res.body) rescue false
    end

    private

    def do_get_request(url)
      conn = Faraday.new do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end
      res = conn.get url
      if res.status < 400
        res
      else
        raise "Could not fetch #{url} successfully (#{res.status})"
      end
    end

    def discover_web_manifest_url(html)
      html.at_css("link[rel=manifest]").attributes["href"].value
    rescue
      false
    end

  end
end
