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

  describe "#fetch_web_manifest" do
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
      end

      let(:web_client) { Manifique::WebClient.new(url: "https://kosmos.social") }

      subject { web_client.fetch_web_manifest }

      it "fetches and returns the manifest" do
        expect(subject).to be_kind_of(Hash)
        expect(subject["name"]).to eq("kosmos.social")
      end
    end
  end
end
