# 这个paperclip的url插入仅用于Video模型
Paperclip.interpolates :content_type_extension do |attachment, style|
# debugger
  case
  # 当附件的Paperclip::Style不为空,且其文件格式存在时，返回其文件格式
  when ((s = attachment.styles[style]) && !s[:format].blank?) then s[:format]
  # 当附件为视频文件且Paperclip::Style为已编码的话，文件后缀为flv
  # when attachment.instance.video? && style.to_s == 'transcoded' then 'flv'
  when style.to_s == 'transcoded' then 'flv' # 仅用于video模型，不需要再判断是否为视频文件
  # 当文件为视频文件且Paperclip::Style不为原始文件话，文件后缀为jpg
  # when attachment.instance.video? && style.to_s != 'original' then 'jpg'
  when style.to_s != 'original' then 'jpg' # 仅用于video模型，不需要再判断是否为视频文件
  # 其它如Paperclip::Style为原始文件时，返回原始文件的后缀
  else
    File.extname(attachment.original_filename).gsub(/^\.+/, "")
  end
end
