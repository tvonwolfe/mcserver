# frozen_string_literal: true

class ServerInstanceFactory
  def get_server(server_jar_path)
    ServerInstance.new(server_jar_path)
  end
end
