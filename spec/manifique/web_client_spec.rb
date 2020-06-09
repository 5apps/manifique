require "spec_helper"
require "manifique/web_client"

RSpec.describe Manifique::WebClient do

  describe "#do_get_request" do
    before do
      stub_request(:get, "http://example.com/404").
        to_return(body: "", status: 404, headers: {})

      stub_request(:get, "http://example.com/500").
        to_return(body: "", status: 500, headers: {})

      stub_request(:get, "http://example.com/200_empty").
        to_return(body: "", status: 200, headers: {})

      stub_request(:get, "http://example.com/failed").
        to_raise(Faraday::ConnectionFailed)
      stub_request(:get, "http://example.com/timeout").
        to_raise(Faraday::TimeoutError)
      stub_request(:get, "http://example.com/ssl_error").
        to_raise(Faraday::SSLError)
    end

    context "unsuccessful requests" do
      describe "404" do
        let(:client) { Manifique::WebClient.new }

        it "raises an exception" do
          expect {
            client.send(:do_get_request, 'http://example.com/404')
          }.to raise_error { |error|
            expect(error).to be_a(Manifique::Error)
            expect(error.message).to eq("Failed with HTTP status 404")
            expect(error.type).to eq("http_404")
            expect(error.url).to eq("http://example.com/404")
          }
        end
      end

      describe "500" do
        let(:client) { Manifique::WebClient.new }

        it "raises an exception" do
          expect {
            client.send(:do_get_request, 'http://example.com/500')
          }.to raise_error { |error|
            expect(error).to be_a(Manifique::Error)
            expect(error.message).to eq("Failed with HTTP status 500")
            expect(error.type).to eq("http_500")
            expect(error.url).to eq("http://example.com/500")
          }
        end
      end

      describe "failed connections" do
        let(:client) { Manifique::WebClient.new }

        it "raises an exception on connection failures" do
          expect {
            client.send(:do_get_request, 'http://example.com/failed')
          }.to raise_error { |error|
            expect(error).to be_a(Manifique::Error)
            expect(error.message).to eq("Failed to connect")
            expect(error.type).to eq("connection_failed")
            expect(error.url).to eq("http://example.com/failed")
          }
        end

        it "raises an exception on timouts" do
          expect {
            client.send(:do_get_request, 'http://example.com/timeout')
          }.to raise_error("Failed to connect")
        end

        it "raises an exception on SSL errors" do
          expect {
            client.send(:do_get_request, 'http://example.com/ssl_error')
          }.to raise_error("Failed to connect")
        end
      end
    end

    context "successful requests" do
      describe "200" do
        let(:client) { Manifique::WebClient.new }

        subject { client.send(:do_get_request, 'http://example.com/200_empty') }

        it "returns the response" do
          expect(subject.status).to eq(200)
        end
      end
    end
  end

  describe "#fetch_website" do
    let(:web_client) { Manifique::WebClient.new(url: "https://kosmos.social/") }

    before do
      index_html = File.read(File.join(__dir__, "..", "fixtures", "mastodon.html"));
      stub_request(:get, "https://kosmos.social/").
        to_return(body: index_html, status: 200, headers: {
          "Content-Type": "text/html; charset=utf-8"
        })

      web_client.send(:fetch_website)
    end

    it "instantiates an HTML parser object" do
      html = web_client.instance_variable_get("@html")

      expect(html).to be_kind_of(Nokogiri::HTML::Document)
    end
  end

  describe "#fetch_web_manifest" do
    let(:web_client) { Manifique::WebClient.new(url: "https://kosmos.social/") }

    context "link[rel=manifest] present" do
      before do
        index_html = File.read(File.join(__dir__, "..", "fixtures", "mastodon.html"));
        stub_request(:get, "https://kosmos.social/").
          to_return(body: index_html, status: 200, headers: {
            "Content-Type": "text/html; charset=utf-8"
          })
        manifest = File.read(File.join(__dir__, "..", "fixtures", "mastodon-web-app-manifest.json"));
        stub_request(:get, "https://kosmos.social/mastodon-web-app-manifest.json").
          to_return(body: manifest, status: 200, headers: {
            "Content-Type": "application/json; charset=utf-8"
          })

        web_client.send(:fetch_website)
      end

      subject do
        web_client.send(:fetch_web_manifest)
      end

      it "returns the fetched manifest as a hash" do
        expect(subject).to be_kind_of(Hash)
        expect(subject["name"]).to eq("kosmos.social")
      end
    end

    context "no link[rel=manifest] element found" do
      before do
        index_html = File.read(File.join(__dir__, "..", "fixtures", "mastodon-no-manifest.html"));
        stub_request(:get, "https://kosmos.social/").
          to_return(body: index_html, status: 200, headers: {
            "Content-Type": "text/html; charset=utf-8"
          })

        web_client.send(:fetch_website)
      end

      subject do
        web_client.send(:fetch_web_manifest)
      end

      it "returns false" do
        expect(subject).to be(false)
      end
    end
  end

  describe "#fetch_metadata" do
    let(:web_client) { Manifique::WebClient.new(url: "https://kosmos.social/") }

    context "web app manifest present" do
      before do
        index_html = File.read(File.join(__dir__, "..", "fixtures", "mastodon.html"));
        stub_request(:get, "https://kosmos.social/").
          to_return(body: index_html, status: 200, headers: {
            "Content-Type": "text/html; charset=utf-8"
          })
        manifest = File.read(File.join(__dir__, "..", "fixtures", "mastodon-web-app-manifest.json"));
        stub_request(:get, "https://kosmos.social/mastodon-web-app-manifest.json").
          to_return(body: manifest, status: 200, headers: {
            "Content-Type": "application/json; charset=utf-8"
          })
      end

      subject { web_client.fetch_metadata }

      it "returns a metadata object with the manifest properties loaded" do
        expect(subject).to be_kind_of(Manifique::Metadata)
        expect(subject.name).to eq("kosmos.social")
      end

      it "knows which properties were loaded from the web app manifest" do
        expect(subject.from_web_manifest.length).to eq(10)
      end

      it "loads iOS icons from HTML" do
        apple_touch_icons = subject.icons.select{|i| i["purpose"] == "apple-touch-icon"}
        expect(apple_touch_icons.length).to eq(1)
        expect(apple_touch_icons.first["type"]).to eq("image/png")
        expect(apple_touch_icons.first["sizes"]).to eq("180x180")
      end

      it "loads SVG mask icons from HTML" do
        mask_icon = subject.icons.find{|i| i["purpose"] == "mask-icon"}
        expect(mask_icon["color"]).to eq("#2b90d9")
        expect(mask_icon["type"]).to eq("image/svg")
        expect(mask_icon["sizes"]).to be_nil
      end
    end

    context "no web app manifest present" do
      before do
        index_html = File.read(File.join(__dir__, "..", "fixtures", "mastodon-no-manifest.html"));
        stub_request(:get, "https://kosmos.social/").
          to_return(body: index_html, status: 200, headers: {
            "Content-Type": "text/html; charset=utf-8"
          })
      end

      subject { web_client.fetch_metadata }

      it "returns a metadata object" do
        expect(subject).to be_kind_of(Manifique::Metadata)
      end

      it "loads properties from parsed HTML" do
        expect(subject.name).to eq("kosmos.social")
        expect(subject.description).to eq("A friendly place for tooting")
        expect(subject.theme_color).to eq("#282c37")
        expect(subject.display).to eq("standalone")
      end

      it "loads icons from link[rel=icon] elements" do
        png_icons = subject.icons.select{|i| i["type"] == "image/png"}
        expect(png_icons.length).to eq(7)
        expect(subject.icons.find{|i| i["sizes"] == "512x512"}["src"]).to eq( "/application_icon_x512.png")
      end

      it "loads icons from link[rel=apple-touch-icon] elements" do
        apple_touch_icons = subject.icons.select{|i| i["purpose"] == "apple-touch-icon"}
        expect(apple_touch_icons.length).to eq(2)
        expect(apple_touch_icons.first["type"]).to eq("image/png")
        expect(apple_touch_icons.first["sizes"]).to eq("180x180")
      end

      it "loads mask icons from link[rel=mask-icon] elements" do
        mask_icon = subject.icons.find{|i| i["purpose"] == "mask-icon"}
        expect(mask_icon["color"]).to eq("#2b90d9")
        expect(mask_icon["type"]).to eq("image/svg")
        expect(mask_icon["sizes"]).to be_nil
      end

      it "knows which properties were loaded from HTML" do
        %w{ name description theme_color display icons }.each do |property|
          expect(subject.from_html).to include(property)
        end
      end
    end

    context "with data URL icons" do
      before do
        index_html = File.read(File.join(__dir__, "..", "fixtures", "kommit.html"));
        stub_request(:get, "https://kosmos.social/").
          to_return(body: index_html, status: 200, headers: {
            "Content-Type": "text/html; charset=utf-8"
          })
      end

      subject { web_client.fetch_metadata }

      it "returns a metadata object" do
        expect(subject).to be_kind_of(Manifique::Metadata)
      end

      it "loads properties from parsed HTML" do
        expect(subject.name).to eq("Kommit")
        expect(subject.description).to eq("Augment your memory")
      end

      it "ignores data URL icons" do
        expect(subject.icons.length).to eq(1)
      end

      it "loads icons from link[rel=apple-touch-icon] elements" do
        apple_touch_icons = subject.icons.select{|i| i["purpose"] == "apple-touch-icon"}
        expect(apple_touch_icons.length).to eq(1)
        expect(apple_touch_icons.first["type"]).to eq("image/jpg")
        expect(apple_touch_icons.first["sizes"]).to be_nil
      end
    end
  end

end
