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

  describe "#select_icon" do
    let(:metadata) { Manifique::Metadata.new }

    before do
      metadata.icons = icon_fixtures
    end

    it "expects at least one filter option" do
      expect { metadata.select_icon }.to raise_error(ArgumentError)
    end

    describe "by purpose" do
      it "returns the correct icon" do
        icon = metadata.select_icon(purpose: "mask-icon")
        expect(icon["src"]).to eq("/mask-icon.svg")
      end
    end

    describe "by type" do
      it "returns the largest image of the type" do
        icon = metadata.select_icon(type: "image/png")
        expect(icon["sizes"]).to eq("512x512")
      end
    end

    describe "by size" do
      it "returns the exact size when available" do
        icon = metadata.select_icon(sizes: "256x256")
        expect(icon["sizes"]).to eq("256x256")
      end

      it "returns the icon with the closest (but larger) size" do
        icon = metadata.select_icon(sizes: "180x180")
        expect(icon["sizes"]).to eq("192x192")
      end
    end

    describe "special purpose by size" do
      it "returns the exact size when available" do
        icon = metadata.select_icon(purpose: "apple-touch-icon", sizes: "180x180")
        expect(icon["sizes"]).to eq("180x180")
      end

      it "returns the icon with the closest (but larger) size" do
        icon = metadata.select_icon(purpose: "apple-touch-icon", sizes: "44x44")
        expect(icon["sizes"]).to eq("57x57")
      end
    end
  end

end

def icon_fixtures
  [
    {"src"=>"/favicon.ico", "sizes"=>nil, "type"=>"image/x-icon"},
    {"src"=>"/application_icon_x512.png", "sizes"=>"512x512", "type"=>"image/png"},
    {"src"=>"/application_icon_x256.png", "sizes"=>"256x256", "type"=>"image/png"},
    {"src"=>"/application_icon_x228.png", "sizes"=>"228x228", "type"=>"image/png"},
    {"src"=>"/application_icon_x196.png", "sizes"=>"196x196", "type"=>"image/png"},
    {"src"=>"/application_icon_x192.png", "sizes"=>"192x192", "type"=>"image/png"},
    {"purpose"=>"apple-touch-icon", "src"=>"/apple-touch-icon.png", "sizes"=>"180x180", "type"=>"image/png" },
    {"purpose"=>"apple-touch-icon", "src"=>"/apple-touch-icon-57px.png", "sizes"=>"57x57", "type"=>"image/png"},
    {"purpose"=>"mask-icon", "src"=>"/mask-icon.svg", "type"=>"image/svg", "color"=>"#2b90d9"}
  ]
end
