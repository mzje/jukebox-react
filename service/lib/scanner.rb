# encoding: utf-8
class Scanner

  def initialize(path = JUKEBOX_MUSIC_PATH)
    @path = path
    @ctime = 0
  end

  attr_writer :ctime

  EXCLUDE_EXPRESSIONS = [%r{^find:(.+): Host is down$}, %r{^find:(.+): No such file or directory$}]

  def start_updates
    directories = sanitised_list
    return nil if directories.empty?
    Rails.logger.info "*** FOUND THE FOLLOWING DIRECTORIES TO UPDATE"
    Rails.logger.info directories.join(', ')
    mpd = MPD.instance
    result = mpd.update(directories)
    Rails.logger.info "*** #{result}"
    return result
    mpd.close
  end

  def sanitised_list
    directories = split_directory_list(run_find).select {|dir|
      EXCLUDE_EXPRESSIONS.each do |regex|
        !dir.match(regex)
      end
    }
    remove_top_level_directories(directories)
  end

  def remove_top_level_directories(directories)
    directories.delete_if {|dir|
      !directories.collect {|d| d.match(/^#{regex_escape(dir)}(.+)/) }.compact.empty?
    }
  end

  def split_directory_list(list)
    list.split("\n").uniq.collect {|dir| clean_path(dir) }.delete_if {|dir| dir.blank? }
  end

  def run_find
    `find #{@path} -type f -daystart -ctime #{@ctime} -printf "%h\n"`
  end

  def clean_path(dir)
    dir.gsub!(@path, "")
    dir.gsub!(/^\//, "") if dir.match(/^\//)
    dir.gsub(/ /, "%20")
  end

  def regex_escape(string)
    string.gsub!(/[^\w\\\/]/) {|s| "\\" + s }
  end

end
