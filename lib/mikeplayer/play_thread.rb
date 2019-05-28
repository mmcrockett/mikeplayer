module MikePlayer
  class PlayThread
    def self.run(file, volume)
      args = [
        :play,
        '--no-show-progress',
        '--volume', volume,
        song
      ]
      Open3.popen2e(*args) do |stdin, out, wait_thr|
      end
    end
  end
end
