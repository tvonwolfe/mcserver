module MCServer
  class WorldError < StandardError
    def initialize(msg = "Something is wrong with this world or server")
      super
    end
  end
end
