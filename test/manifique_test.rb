require "test_helper"

class ManifiqueTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Manifique::VERSION
  end

  def test_fetch_metadata
    agent = Manifique::Agent.new(url: 'https://example.com')
    assert_equal agent.fetch_metadata, 'https://example.com'
  end
end
