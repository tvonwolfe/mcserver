require 'json'
require 'open3'

module MCServer
  class World
    DEFAULT_PORT = 25_565
    attr_reader :world_path

    # World object constructor
    # @param world_path [String] path to the directory that contains the
    #   world's data & config files.
    def initialize(world_path)
      @server_pid = nil
      @world_path = world_path
      @log_file_path = "#{@world_path}/logs/latest.log"
      @log_stream = nil
      @stdin_stream = nil
    end

    # Returns true if the server is running
    # @return [Boolean] whether the server is running or not
    def running?
      return false if !server_pid
      Process.kill(0, server_pid)
      true
    rescue Errno::ESRCH
      server_pid = nil
      false
    end

    # Starts the server if it's stopped
    # param min_mem [Integer] lowest amount of memory to use, in MB
    # param max_mem [Integer] highest amount of memory to use, in MB
    # param options [Array] array containing option arguments for the server JAR
    # return [Integer] PID of the running server.
    def start(min_mem: 1024, max_mem: 2048, options: [:nogui])
      startup_command = "java -Xmx#{max_mem}M -Xms#{min_mem}M -jar #{world_path}/server.jar #{interpolate_options(options)}"
      unless running?
        FileUtils.rm(log_file_path)

        @stdin_stream, _, wait_thr = Open3.popen2(startup_command, chdir: world_path)
        raise WorldError, 'Could not start this world' unless wait_thr

        @server_pid = wait_thr.pid

        until File.exist?(log_file_path)
          raise WorldError, 'Log file not created' if not running?
        end

        @log_stream = File.open(log_file_path)

        server_pid
      end
    end

    # Stops the server
    def stop
      run_cmd('stop')
      log_stream.close
      stdin_stream.close
      server_pid = nil
    end

    # Stops the server unpolitely
    def kill
      Process.kill(Signal.list["TERM"], server_pid)
      server_pid = nil
    end

    def process_logs(pattern)
    end

    def run_cmd(cmd)
      raise WorldError, 'World must be started to run commands.' unless running?
      stdin_stream.write("#{cmd}\n")
    end

    def say(msg)
      run_cmd("say #{msg}")
    end

    def seed
      run_cmd("seed")
      # TODO: parse log output for seed
    end

    def ban_player(target); end

    def ban_ip(ip_addr); end

    def pardon(target); end

    def pardon_ip(ip_addr); end

    def difficulty=(difficulty); end

    def difficulty 
      diff = 'difficulty'
      run_cmd(diff)
    end

    # private

    attr_accessor :server_pid, :stdin_stream, :log_stream, :world_path, :log_file_path

    # Modifies the `eula.txt` file that is generated from executing the server
    # JAR file to accept the Minecraft EULA.
    def accept_eula
      File.open("#{File.dirname(world_path)}/eula.txt") do |file|
        temp_file = Tempfile.new('accepted_eula.txt')
        file.each_line do |line|
          temp_file.puts(/eula=false/.match?(line) ? 'eula=true' : line)
        end

        file.close
        temp_file.close
        FileUtils.mv(temp_file.path, file.path)
      end
    end

    def interpolate_options(options)
      options_str = ""
      options.reduce(options_str) do |str, option|
        option_as_string = if option.is_a?(Hash)
                             "--#{option.keys.first.to_s.gsub(/_(.)/) do |_s|
                                    Regexp.last_match(1).upcase
                                  end } #{option[option.keys.first]}"
                           else
                             "--#{option.to_s.gsub(/_(.)/) { |_s| Regexp.last_match(1).upcase }}"
                           end
        str.concat(option_as_string).concat(' ')
      end.strip
    end

    def delete_log_file
    end

    class Properties < Hash
      GAMEMODES = %w[survival creative adventure spectator].freeze
      DIFFICULTIES = %w[peaceful easy normal hard].freeze
      LEVEL_TYPE = %w[default flat largeBiomes amplified].freeze
      DEFAULT_MOTD = 'A Minecraft Server'
      OPS_PERMISSIONS = [*1..4].freeze

      # Dump the properties out to a `server.properties` file in the world
      # folder.
      # @param world_path [String] path to the world folder, where the file will
      #   be written.
      def dump_to_file(world_path)
        Tempfile.open('server.properties') do |file|
          file.write(as_jproperties)
          file.close
          FileUtils.mv(file.path, properties_file_path(world_path))
        end
      end

      def self.read_from_file(world_path)
        raise WorldError, 'Properties file not found' unless File.exist?(properties_file_path(world_path))
        lines = File.readlines(properties_file_path(world_path))
        new.merge(
          lines.select { |line| line.include?('=') }.map(&:strip)
            .map { |line| line.split('=') }
            .map { |prop_line| prop_line.length == 1 ? prop_line.push(nil) : prop_line }.to_h)
      end

      private

      # Return the properties object as a string that's compatible with the 'jproperties' file
      # format.
      # @return [String] the properties object in string format that's
      #   compatible with 'jproperties' file format
      def as_jproperties
        reduce('') do |str, pair|
          str.concat("#{pair.first}=#{pair.last}\n")
        end
      end

      def self.properties_file_path(world_path)
        "#{world_path}/server.properties"
      end
    end
  end
end
