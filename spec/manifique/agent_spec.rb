require "spec_helper"

RSpec.describe Manifique::Agent do

  describe "options" do
    describe "URL validation" do
      context "with invalid URL" do
        it "raises an exception" do
          expect { Manifique::Agent.new }.to raise_error(RuntimeError)
          expect { Manifique::Agent.new(url: "htp://example.com") }.to raise_error(RuntimeError)
        end
      end

      context "with valid URL" do
        subject { Manifique::Agent.new(url: "https://example.com") }

        it "creates the instance" do
          expect(subject.class).to eq(Manifique::Agent)
        end
      end
    end
  end

  describe "#fetch_metadata" do

  end

end
