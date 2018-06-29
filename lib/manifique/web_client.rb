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

    def fetch_web_manifest
      res = do_get_request @url
      links = parse_http_link_header(res)
      doc = Nokogiri::HTML(res.body)
      manifest_url = discover_web_manifest_url(links, doc)

      unless manifest_url.match(/^https?\:\/\//)
        # Link is just the manifest path, not an absolute URL
        manifest_url = @url + manifest_url
      end

      res = do_get_request manifest_url

      begin
        manifest_data = JSON.parse(res.body)
      rescue
        manifest_data = false
      end

      manifest_data
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

    def discover_web_manifest_url(links, doc)
      # TODO implement/test link header discovery
      # if url = links.by_rel('manifest').target.to_s or
      if url = doc.at_css("link[rel=manifest]").attributes["href"].value
        return url
      else
        raise "No Web App Manifest found on #{@url}"
      end
    end
  end
end
