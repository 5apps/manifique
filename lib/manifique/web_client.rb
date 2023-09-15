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
        parse_apple_touch_icons_from_html
        parse_mask_icon_from_html
      else
        parse_metadata_from_html
      end

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

    def parse_metadata_from_html
      parse_title_from_html
      parse_meta_elements_from_html
      parse_display_mode_from_html
      parse_icons_from_html
    end

    def parse_title_from_html
      return if @metadata.name

      if title = @html.at_css("title") and !title.text.empty?
        @metadata.name = title.text
        @metadata.from_html.add "name"
      end
    end

    def parse_meta_elements_from_html
      {
        description: "description",
        theme_color: "theme-color"
      }.each do |prop, name|
        next if @metadata.send("#{prop}")
        if value = get_meta_element_value(name)
          @metadata.send "#{prop}=", value
          @metadata.from_html.add prop.to_s
        end
      end
    end

    def parse_display_mode_from_html
      return if @metadata.display
      if get_meta_element_value("apple-mobile-web-app-capable") == "yes"
        @metadata.display = "standalone"
        @metadata.from_html.add "display"
      end
    end

    def get_meta_element_value(name)
      if el = @html.at_css("meta[name=#{name}]") and !el.attributes["content"].value.empty?
        el.attributes["content"].value
      end
    end

    def parse_icons_from_html
      parse_link_icons_from_html
      parse_apple_touch_icons_from_html
      parse_mask_icon_from_html
    end

    def parse_link_icons_from_html
      if icon_links = @html.css("link[rel=icon]")
        icon_links.each do |link|
          icon = {}
          icon["src"] = link.attributes["href"].value rescue nil
          next unless is_adequate_src(icon["src"])
          icon["sizes"] = link.attributes["sizes"].value rescue nil
          icon["type"]  = link.attributes["type"].value rescue get_icon_type(icon["src"])
          @metadata.icons.push icon
          @metadata.from_html.add "icons"
        end
      end
    end

    def parse_apple_touch_icons_from_html
      if icon_links = @html.css("link[rel=apple-touch-icon]")
        icon_links.each do |link|
          icon = { "purpose" => "apple-touch-icon" }
          icon["src"] = link.attributes["href"].value rescue nil
          next unless is_adequate_src(icon["src"])
          icon["sizes"] = link.attributes["sizes"].value rescue nil
          icon["type"]  = link.attributes["type"].value rescue get_icon_type(icon["src"])
          @metadata.icons.push icon
          @metadata.from_html.add "icons"
        end
      end
    end

    def parse_mask_icon_from_html
      if mask_icon_link = @html.at_css("link[rel=mask-icon]")
        icon = { "purpose" => "mask-icon" }
        icon["src"] = mask_icon_link.attributes["href"].value rescue nil
        return unless is_adequate_src(icon["src"])
        icon["type"]  = link.attributes["type"].value rescue get_icon_type(icon["src"])
        icon["color"] = mask_icon_link.attributes["color"].value rescue nil
        @metadata.icons.push icon
        @metadata.from_html.add "icons"
      end
    end

    def is_data_url?(src)
      !!src.match(/^data:/)
    end

    def is_adequate_src(src)
      !src.to_s.empty? && !is_data_url?(src)
    end

    def get_icon_type(src)
      extension = src.match(/\.([a-zA-Z]+)$/)[1]
      return "image/#{extension}"
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
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError => e
      raise Manifique::Error.new "Failed to connect", "connection_failed", url
    end

    def discover_web_manifest_url(html)
      html.at_css("link[rel=manifest]").attributes["href"].value
    rescue
      false
    end
  end
end
