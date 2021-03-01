module MikePlayer
  class PlayThread
    def initialize(volume: 1.0)
      check_system

      @pid     = nil
      @volume  = volume
      @start_t = 0
      @elapsed = 0
      @paused  = false
    end

    def play(file)
      start_position = 0

      if paused?
        start_position = @elapsed
      else
        @elapsed = 0
      end

      start_thread(file: file, start_position: start_position)

      @start_t = Time.now.to_i
    end

    def stop
      pause

      @elapsed = 0
      @start_t = 0
      @paused  = false
    end

    def pause
      kill('INT')

      @elapsed += Time.now.to_i - @start_t
      @start_t  = 0

      10.times do
        break unless alive?

        sleep 0.1
      end

      kill('KILL')

      10.times do
        break unless alive?

        sleep 0.1
      end

      @paused = true
    end

    def kill(signal)
      Process.kill(signal, @pid) if alive?
    end

    def alive?
      MikePlayer::PlayThread.alive?(@pid)
    end

    def stopped?
      false == alive?
    end

    def paused?
      @paused && stopped?
    end

    def playing?
      alive?
    end

    def elapsed
      return (@elapsed + (Time.now.to_i - @start_t)) if @start_t.positive?

      @elapsed
    end

    def self.alive?(pid)
      return system("ps -p #{pid} > /dev/null") unless pid.nil?

      false
    end

    def self.cmd_exist?(cmd)
      if @test_cmd.nil?
        if system('command')
          @test_cmd = 'command -v'
        elsif system('bash -c "command"')
          @test_cmd = 'bash -c "command -v"'
        else
          raise "Missing 'command' command, which is used to test compatibility."
        end
      end

      if (true != system("#{@test_cmd} #{cmd} >/dev/null 2>&1"))
        return false
      end

      return true
    end

    private
    def start_thread(file:, start_position: )
      args = [
        'play',
        '--no-show-progress',
        '--volume', @volume.to_s,
        file,
        'trim', start_position.to_s,
      ]

      stdin, stdother, thread_info = Open3.popen2e(*args)

      @pid = thread_info.pid

      10.times do
        break if alive?

        sleep 0.2
      end

      raise "Failed to play #{stdother.read}" unless alive?

      stdin.close
      stdother.close

      self
    end

    def check_system
      %w[play].each do |cmd|
        raise "#{cmd} failed, do you have sox installed?" unless MikePlayer::PlayThread.cmd_exist?(cmd)
      end
    end
  end
end
