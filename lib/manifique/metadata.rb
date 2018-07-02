module Manifique
  class Metadata

    attr_accessor :url, :from_web_manifest, :from_html,
                  :name, :short_name, :description, :icons,
                  :theme_color, :background_color, :display,
                  :start_url, :scope, :share_target

    def initialize(data={})
      self.url = data[:url]
      self.from_web_manifest = []
      self.from_html = []
      self.icons = []
    end

    def load_from_web_manifest(manifest)
      [ :name, :short_name, :description, :icons,
        :theme_color, :background_color, :display,
        :start_url, :scope, :share_target ].map(&:to_s).each do |prop|
         self.send("#{prop}=", manifest[prop]) if manifest[prop]
         self.from_web_manifest.push(prop)
      end
    end

    def to_json
      # TODO serialize into JSON
    end

  end
end
