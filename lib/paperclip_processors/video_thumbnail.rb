module Paperclip
  # 截图的paperclip processer
  # TODO 不直接调用ffmpeg，用rvideo封装截图命令
  # TODO 截图后用thumbnail里的方法调整图片尺寸
  class VideoThumbnail < Processor

    # The VideoThumbnail processor accepts three options:
    ### :time_offset
    # The number of seconds into the video to capture as a thumbnail 
    # (this should be a negative number and corresponds to the itsoffset option for FFmpeg).
    ### :geometry
    # Accepts a wxh geometry string, ideally both the width 
    # and height should be even numbers however 
    # if they aren’t the processor will adjust them automatically.
    ### :whiny
    # Determines whether or not thumbnailing errors are to be reported.
    attr_accessor :time_offset, :geometry, :whiny

    def initialize(file, options = {}, attachment = nil)
      super
      @time_offset = options[:time_offset] || '-4'
      unless options[:geometry].nil? || (@geometry = Geometry.parse(options[:geometry])).nil?
        @geometry.width = (@geometry.width / 2.0).floor * 2.0
        @geometry.height = (@geometry.height / 2.0).floor * 2.0
        @geometry.modifier = ''
      end
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @basename = File.basename(file.path, File.extname(file.path))
    end

    def make
      dst = Tempfile.new([ @basename, 'jpg' ].compact.join("."))
      dst.binmode

      cmd = %Q[-itsoffset #{time_offset} -i "#{File.expand_path(file.path)}" -y -vcodec mjpeg -vframes 1 -an -f rawvideo ]
      cmd << "-s #{geometry.to_s} " unless geometry.nil?
      cmd << %Q["#{File.expand_path(dst.path)}"]

      begin
        success = Paperclip.run('ffmpeg', cmd)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if whiny
      end
      dst
    end
  end
end