require "spec_helper"
require "manifique/web_client"

RSpec.describe Manifique::WebClient do
  before do
    stub_request(:get, "http://example.com/200_empty").
      to_return(body: "", status: 200, headers: {})

    stub_request(:get, "http://example.com/404").
      to_return(body: "", status: 404, headers: {})

    stub_request(:get, "http://example.com/500").
      to_return(body: "", status: 500, headers: {})
  end

  describe "#do_get_request" do
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
end
