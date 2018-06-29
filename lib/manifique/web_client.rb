require 'faraday'
require 'faraday_middleware'
require "nokogiri"
require 'nitlink/response'

require 'pry'

module Manifique
  class WebClient
    def initialize(options={})
      @options = options
      @url = options[:url]
    end

    def fetch_website
      res = do_get_request @url
      @links = parse_http_link_header(res)
      @html = Nokogiri::HTML(res.body)
    end

    def fetch_web_manifest
      return false unless manifest_url = discover_web_manifest_url(@html)

      unless manifest_url.match(/^https?\:\/\//)
        # Link is just the manifest path, not an absolute URL
        manifest_url = @url + manifest_url
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
      if res.status > 400
        raise "Could not fetch #{url} successfully (#{res.status})"
      else
        res
      end
    end

    def parse_http_link_header(response)
      link_parser = Nitlink::Parser.new
      link_parser.parse(response)
    end

    def discover_web_manifest_url(html)
      html.at_css("link[rel=manifest]").attributes["href"].value
    rescue
      false
    end
  end
end
