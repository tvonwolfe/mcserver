# frozen_string_literal: true

require 'date'

module MCServer
  class World
    def initialize(server_jar_path)
      @server_proc = nil
      @jar_path = server_jar_path
      @stdout_stream = nil
      @stdin_stream = nil
      @ops = nil
      @properties = Properties.new
    end

    def running?
      @server_proc != nil
    end

    def start
    end

    def stop; end

    def read_logs; end

    def clear_logs; end

    def run_cmd(cmd); end

    def upgrade; end

    attr_reader :jar_path

    private

    def accept_eula
      File.open("#{File.dirname(jar_path)}/eula.txt") do |file|
        temp_file = Tempfile.new('accepted_eula.txt')
        file.each_line do |line|
          temp_file.puts(/eula=false/.match?(line) ? 'eula=true' : line)
        end

        temp_file.close
        file.close
        FileUtils.mv(temp_file.path, file.path)
      end
    end
  end
end
