module ManifiqueFixtures

  def mock_connection(urls={})
    Faraday.new do |builder|
      builder.response :json, :content_type => /\bjson$/
      builder.adapter :test do |stub|
        urls.each do |http_method, requests|
          requests.each do |url, fixture|
            stub.send(http_method, url) { |env| [ 200, {'Content-Type' => 'application/json'}, manifique_fixture(fixture) ]}
          end
        end
        yield stub if block_given?
      end
    end
  end

  # returns the content of a fixture file (fixtures/file.json)
  # if no file is found it will just return the provided param...
  # (assuming we then don't care about real bitgo contents but just check for a response vale)
  def manifique_fixture(file)
    path = File.join(File.expand_path(File.dirname(__FILE__)), '../fixtures', "#{file}.json")
    if File.exists?(path)
      File.read(path)
    else
      file.to_json # returning the provided param - asuming we don't care about real bitgo values and just check for a response
    end
  end
end
