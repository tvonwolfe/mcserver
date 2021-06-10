# frozen_string_literal: true

module MCServer
  class WorldFactory
    def get_server(server_jar_path)
      World.new(server_jar_path)
    end
  end
end
