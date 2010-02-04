# 视频管理控制器。只有特定角色能使用本控制器
class Admin::VideosController < ApplicationController

  before_filter :find_video, :only => [:show, :edit, :update, :destroy, :rm]
  
  # acl9插件提供的访问控制列表DSL
  access_control do
    allow :admin, :except => :rm
    allow :owner
  end
  
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      if params[:state]
        @videos = @user.videos.being(params[:state]).paginate(:page => params[:page], 
                                                     :order => 'created_at DESC', 
                                                     :per_page => 6) 
      else
        @videos = Video.paginate(:page => params[:page], 
                               :order => 'created_at DESC', 
                               :per_page => 6)
      end
      render :template => "admin/users/show"
    else
      if params[:state]
        @videos = Video.being(params[:state]).paginate(:page => params[:page], 
                                                  :order => 'created_at DESC', 
                                                  :per_page => 6)
      else
        @videos = Video.paginate(:page => params[:page], 
                                 :order => 'created_at DESC', 
                                 :per_page => 6)
      end
    end

  end

  # 显示视频编码详细信息
  # 有原始视频和编码后的视频
  def show
  end

  def edit
    @video.meta_info
  end
  
  def update
    case  params[:commit]
    when "审核通过"
      begin 
        @video.audit! # 通过审核
        @video.queue! # 放入编码队列
        flash[:notice] = "审核已通过,已将视频放入编码队列"
      rescue StateMachine::InvalidTransition
        flash[:notice] = "已通过审核"
      end
    when "提交更新"
      @video.update_attributes(params[:video])
      flash[:notice] = "内容已更新"
    when "重新生成缩略图"
      @video.asset.reprocess!
      flash[:notice] = "缩略图已重新生成"
    when "中止编码"
      @video.cancel!
      flash[:notice] = "已中止编码,视频改为待处理状态"
    when "取消审核"
      @video.cancel!
      flash[:notice] = "已取消审核,视频改为待处理状态"
    when "重置视频"
      @video.resume!
      flash[:notice] = "已更改为待处理状态"
    when "恢复该视频"
      @video.resume!
      flash[:notice] = "已更改为待处理状态"
    when "不需编码"
      @video.cancel!
      @video.resume!
      @video.audit!
      @video.no_encode!
      flash[:notice] = "不编码，已发布原始视频"
    when "手动编码"
      @video.fore_encode! # 将状态改为编码中才可使用paperclip的video_encoding processer
      begin
        begun_at = Time.now
        @video.started_encoding_at = begun_at
        @video.asset.reprocess! # 用paperclip processor处理视频编码
        @video.converted! # 编码结束
        ended_at = Time.now
        @video.encoded_at = ended_at
        @video.save!
        @video.encoding_time = ended_at - begun_at
        flash[:notice] = "视频已手动编码完成"
      rescue
        @video.failure! # 编码出错
        flash[:notice] = "编码时出错"
      end
    end
    redirect_to edit_admin_video_path(@video)
  end

  # 软删除视频
  def destroy
    begin
      @video.soft_delete!
      flash[:notice] = "视频已被删除"
    rescue StateMachine::InvalidTransition => e
      if e == "Cannot transition state via :soft_delete from :soft_deleted"
        flash[:notice] = "视频已被删除,无须再次删除"
      else
        flash[:error] = "出错，请联系管理员"
      end
    end
    redirect_to admin_videos_path    
  end
  
  # 物理删除视频
  def rm
    @video.destroy
    flash[:notice] = "视频已被物理删除"
    redirect_to admin_videos_path 
  end
  
private

  def find_video
    @video = Video.find(params[:id])
  end

end
