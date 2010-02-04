# 角色管理控制器。只有特定角色能使用本控制器
class Admin::RolesController < ApplicationController
  
  # acl9插件提供的访问控制列表DSL
  access_control do
    allow :admin
  end  
  
  before_filter :find_role, :only => [:show, :edit, :update, :destroy]

  def index
    if params[:state]
      @roles = Role.being(params[:state]).paginate(:page => params[:page], 
                                                     :order => 'created_at DESC', 
                                                     :per_page => 6)
    else
      @roles = Role.paginate(:page => params[:page], 
                               :order => 'created_at DESC', 
                               :per_page => 6)
    end
  end

  def show
    @role=Role.find(params[:id])
    @users_in_role = @role.users.find(:all, :select => "id, login")
    all_user = User.find(:all, :select => "id, login")
    @users_out_role = ( all_user - @users_in_role).paginate(:page => params[:page],
                                      :order => 'created_at DESC', :per_page => 6) 
  end

  def edit
  end

  def update
    case  params[:commit]
    when "审核通过"
      begin 
        @role.audit! # 通过审核
        @role.queue! # 放入编码队列
        flash[:notice] = "审核已通过,已将视频放入编码队列"
      rescue StateMachine::InvalidTransition
        flash[:notice] = "已通过审核"
      end
    when "提交更新"
      @role.update_attributes(params[:role])
      flash[:notice] = "内容已更新"
    when "重新生成缩略图"
      @role.asset.reprocess!
      flash[:notice] = "缩略图已重新生成"
    when "中止编码" || "取消审核"
      @role.cancel!
      flash[:notice] = "已取消"
    when "重置视频"
      @role.resume!
      flash[:notice] = "已更改为待审核状态"
    when "手动编码"
      @role.fore_encode! # 将状态改为编码中才可使用paperclip的role_encoding processer
      begin
        begun_at = Time.now
        @role.started_encoding_at = begun_at
        @role.asset.reprocess! # 用paperclip processor处理视频编码
        @role.converted! # 编码结束
        ended_at = Time.now
        @role.encoded_at = ended_at
        @role.save!
        @role.encoding_time = ended_at - begun_at
        flash[:notice] = "视频已手动编码完成"
      rescue
        @role.failure! # 编码出错
        flash[:notice] = "编码时出错"
      end
    end
    redirect_to edit_admin_role_path(@role)
  end
  
  # 软删除视频
  def destroy
    begin
      @role.soft_delete!
      flash[:notice] = "视频已被删除"
    rescue StateMachine::InvalidTransition => e
      if e == "Cannot transition state via :soft_delete from :soft_deleted"
        flash[:notice] = "视频已被删除,无须再次删除"
      else
        flash[:error] = "出错，请联系管理员"
      end
    end
    redirect_to admin_roles_path    
  end

private

  def find_role
    @role = Role.find(params[:id])
  end

end
