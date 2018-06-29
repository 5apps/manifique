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
      @metadata = Metadata.new(url: @url)
    end

    def fetch_metadata
      fetch_website
      if manifest = fetch_web_manifest
        @metadata.load_from_web_manifest(manifest)
      else
        parse_metadata_from_html
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

    def parse_metadata_from_html
      if title = @html.at_css("title") and !title.text.empty?
        @metadata.name = title.text
        @metadata.from_html.push "name"
      end
      # TODO extract meta element parsing to seperate method
      if desc = @html.at_css("meta[name=description]") and
         !desc.attributes["content"].value.empty?
        @metadata.description = desc.attributes["content"].value
        @metadata.from_html.push "description"
      end
    end

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
