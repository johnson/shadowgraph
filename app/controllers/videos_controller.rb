class VideosController < ApplicationController
  
  before_filter :find_video, :only => [:show, :edit, :update, :destroy] # 必须在access_control之前取到@video
  
  # acl9插件提供的访问控制列表DSL
  access_control do
    allow all, :to => [:index, :show, :download]    
    allow :admin
    allow logged_in, :to => [:new, :create]
    allow :creator, :editor, :of => :video, :to => [:edit, :update] # :video 是对@video的引用
    # allow logged_in, :except => :destroy     
    # allow anonymous, :to => [:index, :show]
  end

  # skip_before_filter :verify_authenticity_token  # 测试用

  def index
    @videos = Video.publiced.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 12
  end

  def new
    flash[:notice] = "上传视频文件不能超过#{CONFIG['max_upload_file_size']}MB"
    @video = Video.new
  end

  def create
    @video = Video.new(params[:video])
    @video.user = @current_user
    # flash上传的二进制流mime type是 application/octet-stream。
    # 需要给上传的视频文件用mime-type插件获取mime type保存到属性里
    # @video.asset_content_type = MIME::Types.type_for(@video.asset.original_filename).to_s
    @video.asset_content_type = File.mime_type?(@video.asset.original_filename)
    if @video.save
      if request.env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
        # head(:ok, :id => @video.id) and return
        render :text => "id=#{@video.id}"
      else
        # @video.convert
        flash[:notice] = '视频文件已成功上传'
        redirect_to @video
      end
    else
      render :action => 'new'
    end
  end

  def show
    @reply = VideoReply.new
  end

  # 下载文件，通过webserver的x sendfile直接发送文件
  # TODO 可在此完善下载计数器
  # TODO 下载的是原文件名的新文件
  # SEND_FILE_METHOD = 'default' # 配置webserver
  # SEND_FILE_METHOD = 'nginx' # 配置webserver为nginx，nginx需要相应配置X-Sendfile
  SEND_FILE_METHOD = CONFIG['web_server']
  def download
    head(:not_found) and return if (video = Video.find_by_id(params[:id])).nil?
    head(:forbidden) and return unless video.downloadable?(current_user)
    path = video.asset.path(params[:style])
    head(:bad_request) and return unless File.exist?(path) && params[:format].to_s == File.extname(path).gsub(/^\.+/, '')

    send_file_options = { :type => File.mime_type?(path) }

    case SEND_FILE_METHOD
    when 'apache' then send_file_options[:x_sendfile] = true
    when 'nginx' then head(:x_accel_redirect => path.gsub(Rails.root, ''), :content_type => send_file_options[:type]) and return
    end

    send_file(path, send_file_options)
  end

private
 
  def find_video
    @video = Video.find(params[:id])
  end

end
