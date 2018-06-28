require "spec_helper"
require "manifique/web_client"

RSpec.describe Manifique::WebClient do
  before do
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
  end

  # describe "HTTP requests" do
  #   let(:connection) do
  #     Faraday.new do |builder|
  #       builder.adapter :test do |stub|
  #         stub.get('/api/v2/cake') { |env| [ 200, {}, env.params.to_json ]}
  #         stub.post('/api/v2/pizza/body') { |env| [ 200, {}, env.body ]}
  #         stub.post('/api/v2/pizza/query') { |env| [ 200, {}, env.params.to_json ]}
  #         stub.delete('/api/v2/gluhwein') { |env| [ 200, {}, 'delete' ]}
  #       end
  #     end
  #   end
  #
  #   it "requests via get" do
  #     expect(subject).to receive(:connection).and_return(connection)
  #     expect(subject.get('/cake', {query: 'coffee'}).body).to eql('{"query":"coffee"}')
  #   end
  # end
end
