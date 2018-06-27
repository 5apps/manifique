require "test_helper"

class ManifiqueTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::Manifique::VERSION
  end

  def test_init_without_url
    assert_raises(RuntimeError) { Manifique::Agent.new }
  end

  def test_init_with_invalid_url
    assert_raises(RuntimeError) { Manifique::Agent.new(url: "htp:/foo.com") }
  end

  def test_fetch_metadata_request_404
    stub_request(:get, "http://example.com/404").
      to_return(body: "", status: 404, headers: {})

    agent = Manifique::Agent.new(url: 'http://example.com/404')
    assert_raises(RuntimeError) { agent.fetch_metadata }
  end

  def test_fetch_metadata_request_500
    stub_request(:get, "http://example.com/500").
      to_return(body: "", status: 500, headers: {})

    agent = Manifique::Agent.new(url: 'http://example.com/500')
    assert_raises(RuntimeError) { agent.fetch_metadata }
  end
end
