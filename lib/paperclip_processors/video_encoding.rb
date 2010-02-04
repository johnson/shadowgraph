module Paperclip
  # 视频编码paper processor，用rvideo封装。为和ffmepg0.5兼容，需要安装如下版本的rvideo
  # sudo gem install echoe
  # git clone git://github.com/newbamboo/rvideo.git
  # cd rvideo
  # rake repackage
  # sudo rake install
  # TODO 用recipe模型管理视频编码格式,用profile模型管理各个格式的具体参数
  # 目前只编码为500x375的flv格式
  class VideoEncoding < Processor

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
    
    # TODO 新建时将recipe和profile的参数转换为ffmpeg参数
    def initialize(file, options = {}, attachment = nil)
      super
      # @time_offset = options[:time_offset] || '-4'
      # unless options[:geometry].nil? || (@geometry = Geometry.parse(options[:geometry])).nil?
      #   @geometry.width = (@geometry.width / 2.0).floor * 2.0
      #   @geometry.height = (@geometry.height / 2.0).floor * 2.0
      #   @geometry.modifier = ''
      # end
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @file           = file
      @current_format = File.extname(@file.path)
      @basename       = File.basename(@file.path, @current_format)
    end
    
    # paperclip的processor必须有的方法，在此调用ffmpeg将每个视频编码参数用ffmpeg编码
    def make
      # title:"Flash video SD",  container:"flv", video_bitrate:300, audio_bitrate:48, width:320, height:240, fps:24, position:0, player:"flash"
      input_file_path = @file.path
      dst = Tempfile.new([ @basename, 'flv' ].compact.join("."))
      dst.binmode
      output_file_path = dst.path
      transcoder = RVideo::Transcoder.new
      # 注意参数后的空格！
      recipe = "ffmpeg -i $input_file$ " # 输入文件路径
      recipe += "-ar 22050 " 
      recipe += "-ab 48000 " # 音频码率 $audio_bitrate$
      recipe += "-f flv " # 视频格式
      recipe += "-b 300000 " # 视频码率 $video_bitrate_in_bits$
      recipe += "-r 24 " # 帧速率 $fps$
      # recipe += "-s $resolution$ " # 尺寸 宽x高 $resolution$
      recipe += "-s 500x376 " # 尺寸 宽x高 $resolution$
      recipe += "-y $output_file$ " # 输出文件路径
      recipe += "\nflvtool2 -U $output_file$"
      begin
# debugger
        # transcoder.execute(recipe, {:input_file => input_file_path,
        #                             :output_file => output_file_path,
        #                             :resolution => "500x376"})
        transcoder.execute(recipe, {:input_file => input_file_path,
                                    :output_file => output_file_path})
      rescue
        raise  "There was an error encoding the flv for #{@basename}" if whiny
      end
      dst
    end
  end
end