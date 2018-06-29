require "spec_helper"
require "manifique/metadata"

RSpec.describe Manifique::Metadata do

  describe "#initialize" do
    it "sets the URL when given" do
      metadata = Manifique::Metadata.new(url: "https://5apps.com")
      expect(metadata.url).to eq("https://5apps.com")
    end
  end

  describe "#manifest=" do
    let(:metadata) { Manifique::Metadata.new }
    let(:manifest) { JSON.parse(File.read(File.join(__dir__, "..", "fixtures", "mastodon-web-app-manifest.json"))) }

    before do
      metadata.load_from_web_manifest(manifest)
    end

    it "stores the manifest properties as metadata object properties" do
      expect(metadata.name).to eq("kosmos.social")
      expect(metadata.short_name).to eq("kosmos.social")
      expect(metadata.description).to eq("A friendly place for tooting. Run by the Kosmos peeps.")
      expect(metadata.theme_color).to eq("#282c37")
      expect(metadata.background_color).to eq("#191b22")
      expect(metadata.display).to eq("standalone")
      expect(metadata.start_url).to eq("/web/timelines/home")
      expect(metadata.scope).to eq("https://kosmos.social/")
      expect(metadata.share_target).to eq({ "url_template" => "share?title={title}&text={text}&url={url}"})
      expect(metadata.icons).to eq([
        {
          "src"=>"/android-chrome-192x192.png",
          "sizes"=>"192x192",
          "type"=>"image/png"
        }
      ])
    end
  end

end
