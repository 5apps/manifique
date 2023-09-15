module Manifique
  class Metadata

    attr_accessor :url, :from_web_manifest, :from_html,
                  :name, :short_name, :description, :icons,
                  :theme_color, :background_color, :display,
                  :start_url, :scope, :share_target

    def initialize(data={})
      self.url = data[:url]
      self.from_web_manifest = Set.new
      self.from_html = Set.new
      self.icons = []
    end

    def load_from_web_manifest(manifest)
      [ :name, :short_name, :description, :icons,
        :theme_color, :background_color, :display,
        :start_url, :scope, :share_target ].map(&:to_s).each do |prop|
         next unless manifest[prop]
         self.send("#{prop}=", manifest[prop])
         self.from_web_manifest.add(prop)
      end
    end

    def load_from_html(html)
      @html = html
      parse_title_from_html
      parse_meta_elements_from_html
      parse_display_mode_from_html
      parse_icons_from_html
    end

    def select_icon(options={})
      if options[:type].nil? && options[:sizes].nil? && options[:purpose].nil?
        raise ArgumentError, "Tell me what to do!"
      end

      results = icons.dup

      if options[:purpose]
        results.reject! { |r| r["purpose"] != options[:purpose] }
      end

      if options[:type]
        results.reject! { |r| r["type"] != options[:type] }
      end

      if options[:sizes]
        results.reject! { |r| r["sizes"].nil? }
        results.sort!   { |a, b| sizes_to_i(b["sizes"]) <=> sizes_to_i(a["sizes"]) }

        if icon = select_exact_size(results, options[:sizes])
          return icon
        else
          return select_best_size(results, options[:sizes])
        end
      end

      results.first
    end

    def to_json
      # TODO serialize into JSON
    end

    private

    def parse_title_from_html
      return if self.name

      if title = @html.at_css("title") and !title.text.empty?
        self.name = title.text
        self.from_html.add "name"
      end
    end

    def parse_meta_elements_from_html
      {
        description: "description",
        theme_color: "theme-color"
      }.each do |prop, name|
        next if self.send("#{prop}")
        if value = get_meta_element_value(name)
          self.send "#{prop}=", value
          self.from_html.add prop.to_s
        end
      end
    end

    def parse_display_mode_from_html
      return if self.display

      if get_meta_element_value("apple-mobile-web-app-capable") == "yes"
        self.display = "standalone"
        self.from_html.add "display"
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
      return if self.icons.any?

      if icon_links = @html.css("link[rel=icon]")
        icon_links.each do |link|
          icon = {}
          icon["src"] = link.attributes["href"].value rescue nil
          next unless is_adequate_src(icon["src"])
          icon["sizes"] = link.attributes["sizes"].value rescue nil
          icon["type"]  = link.attributes["type"].value rescue get_icon_type(icon["src"])
          self.icons.push icon
          self.from_html.add "icons"
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
          self.icons.push icon
          self.from_html.add "icons"
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
        self.icons.push icon
        self.from_html.add "icons"
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
      "image/#{extension}"
    end

    def sizes_to_i(str)
      str.match(/(\d+)x/)[1].to_i
    end

    def select_exact_size(results, sizes)
      results.select{|r| r["sizes"] == sizes}[0]
    end

    def select_best_size(results, sizes)
      results.reject! { |r| sizes_to_i(r["sizes"]) < sizes_to_i(sizes) }
      results.last
    end

  end
end
