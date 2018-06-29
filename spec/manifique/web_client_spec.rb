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
    end

    context "unsuccessful requests" do
      describe "404" do
        let(:client) { Manifique::WebClient.new }

        it "raises an exception" do
          expect {
            client.send(:do_get_request, 'http://example.com/404')
          }.to raise_error("Could not fetch http://example.com/404 successfully (404)")
        end
      end

      describe "500" do
        let(:client) { Manifique::WebClient.new }

        it "raises an exception" do
          expect {
            client.send(:do_get_request, 'http://example.com/500')
          }.to raise_error("Could not fetch http://example.com/500 successfully (500)")
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

      web_client.fetch_website
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

        web_client.fetch_website
      end

      subject do
        web_client.fetch_web_manifest
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

        web_client.fetch_website
      end

      subject do
        web_client.fetch_web_manifest
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

      it "returns a metadata object with the HTML properties loaded" do
        expect(subject).to be_kind_of(Manifique::Metadata)
        expect(subject.name).to eq("kosmos.social")
        expect(subject.description).to eq("A friendly place for tooting")
      end

      it "knows which properties were loaded from HTML" do
        expect(subject.from_html).to include("name")
        expect(subject.from_html).to include("description")
      end
    end
  end

end
