module MikePlayer
  class Playlist
    attr_reader :songs

    def initialize(filename)
      @filename = filename
      @songs    = []
      @length   = 0
    
      load_songs

      @loaded_song_count = self.size
    end

    def <<(song)
      if ((true == File.file?(song)) && (false == @songs.any? { |s| s.filename == song }))
        @songs << Song.new(song)
        @length += @songs.last.length
      end

      return self
    end

    def add_random(n, directory)
      files = Dir.glob(File.join(directory, "**", "*.mp3"), File::FNM_CASEFOLD) - @songs

      files.sample(n).each do |file|
        self << file
      end

      return self
    end

    def find_song(file, directory)
      if (true == File.file?(file))
        self << file
      else
        Dir.glob(File.join(directory, "**", "*#{file}*"), File::FNM_CASEFOLD).each do |f|
          self << f
        end
      end

      return self
    end

    def get(i)
      return @songs[i]
    end

    def shuffle!
      @songs.shuffle!

      return self
    end

    def save
      File.open(@filename, 'w') do |f|
        f.puts(JSON.pretty_generate(@songs.map {|s| s.to_json }))
      end
    end

    def name
      return File.basename(@filename, Settings::PL_FILE_ENDING)
    end

    def info
      return "#{self.name} loaded #{@loaded_song_count} songs with length #{Song.as_duration_str(@length)}, added #{self.size - @loaded_song_count}"
    end

    def song_info(i)
      song_i_str = "#{i + 1}".rjust(self.size.to_s.size)

      return "Playing (#{song_i_str}/#{self.size}): #{get(i).info}".freeze
    end

    def size
      return @songs.size
    end

    private

    def load_songs
      if File.file?(@filename)
        JSON.parse(File.read(@filename)).each {|song| self << song}
      end
    end
  end
end
