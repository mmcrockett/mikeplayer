module MikePlayer
  class Song
    attr_reader :filename

    def initialize(filename)
      @filename = filename
      @mp3info  = Mp3Info.new(filename)
    end

    def info
      artist = "#{@mp3info.tag.artist}"
      title  = "#{@mp3info.tag.title}"

      if (true == artist.empty?) && (true == title.empty?)
        return File.basename(@filename, '.mp3')
      elsif (true == artist.empty?)
        artist = "?????"
      elsif (true == title.empty?)
        title  = "?????"
      end

      return "#{artist} - #{title}"
    end

    def length
      return @mp3info.length
    end

    def length_str(elapsed_time)
      return Song.as_duration_str(self.length, elapsed_time)
    end

    def to_json
      return @filename.to_s
    end

    def self.as_duration_str(l, t = nil)
      l_hr  = "%02d" % (l / 3600).floor
      l_min = "%02d" % ((l % 3600 )/ 60).floor
      l_sec = "%02d" % (l % 60)
      e_min = "%02d" % (t / 60).floor unless t.nil?
      e_sec = "%02d" % (t % 60) unless t.nil?

      result = "#{l_min}:#{l_sec}"
      result = "#{l_hr}:#{result}" if l >= 3600
      result = "#{e_min}:#{e_sec} [#{result}]" unless t.nil?

      return result
    end
  end
end
