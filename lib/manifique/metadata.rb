module Manifique
  class Metadata

    attr_accessor :url, :src_web_manifest, :src_html_data,
                  :name, :short_name, :description, :icons,
                  :theme_color, :background_color, :display,
                  :start_url, :scope, :share_target

    def initialize(data={})
      self.url = data[:url]
    end

    def web_manifest=(manifest)
      [:name, :short_name, :description, :icons,
       :theme_color, :background_color, :display,
       :start_url, :scope, :share_target].map(&:to_s).each do |prop|
         self.send("#{prop}=", manifest[prop]) if manifest[prop]
       end
       self.src_web_manifest = manifest
    end

    def to_json
      # TODO serialize into JSON
    end

  end
end
