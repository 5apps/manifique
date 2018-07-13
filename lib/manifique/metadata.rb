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
         self.send("#{prop}=", manifest[prop]) if manifest[prop]
         self.from_web_manifest.add(prop)
      end
    end

    def select_icon(options={})
      if options[:type].nil? && options[:sizes].nil? && options[:purpose].nil?
        raise ArgumentError, "Tell me what to do!"
      end

      results = icons

      if options[:purpose]
        results.reject! { |r| r["purpose"] != options[:purpose] }
      else
        # Do not return special icons by default
        results.reject! { |r| r["purpose"] }
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
