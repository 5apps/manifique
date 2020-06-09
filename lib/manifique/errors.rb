module Manifique
  class Error < ::StandardError
    attr_reader :type, :url

    def initialize(msg="Encountered an error", type="generic", url)
      @type = type
      @url = url
      super(msg)
    end
  end
end
