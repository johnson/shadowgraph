# 用户管理控制器。只有特定角色能使用本控制器
class Admin::UsersController < ApplicationController
  
  layout 'users'
  
  # acl9插件提供的访问控制列表DSL
  access_control do
    allow :admin
  end  
  
  before_filter :find_user, :only => [:show, :edit, :update, :destroy]

  def index
    if params[:state]
      @users = User.being(params[:state]).paginate(:page => params[:page], 
                                                     :order => 'created_at DESC', 
                                                     :per_page => 6)
    else
      @users = User.paginate(:page => params[:page], 
                               :order => 'created_at DESC', 
                               :per_page => 6)
    end
    unless params[:id]
      @user = current_user
    else
      @user = User.find(params[:id])
    end    
  end

  def show
    unless params[:id]
      @user = current_user
    else
      @user = User.find(params[:id])
    end
    if params[:state]
      @videos = @user.videos.being(params[:state]).paginate(:page => params[:page], 
                                                     :order => 'created_at DESC', 
                                                     :per_page => 6)
    else
      @videos = @user.videos.paginate(:page => params[:page], 
                               :order => 'created_at DESC', 
                               :per_page => 6)
    end    
  end

  def edit
  end

  def add
    @role=Role.find(params[:role_id])
    @user=User.find(params[:id])
    @user.has_role!(@role.name)
    redirect_to admin_role_path(@role)
  end
  
  def mv
    @role=Role.find(params[:role_id])
    @user=User.find(params[:id])
    @user.has_no_role!(@role.name)
    redirect_to admin_role_path(@role)       
  end  

  def update
    case  params[:commit]
    when "审核通过"
      begin 
        @user.audit! # 通过审核
        flash[:notice] = "审核已通过"
      rescue StateMachine::InvalidTransition
        flash[:notice] = "已通过审核"
      end
    when "提交更新"
      @user.update_attributes(params[:user])
      flash[:notice] = "帐号已更新"
    when "停权"
      @user.suspend!
      flash[:notice] = "已停权"
    when "复权"
      @user.unsuspend!
      flash[:notice] = "已复权"
    when "恢复该用户"
      @user.resume!
      flash[:notice] = "已更改为待审核状态"
    end
    redirect_to admin_user_path(@user)
  end
  
  # 软删除用户
  def destroy
    begin
      @user.soft_delete!
      flash[:notice] = "视频已被删除"
    rescue StateMachine::InvalidTransition => e
      if e == "Cannot transition state via :soft_delete from :soft_deleted"
        flash[:notice] = "视频已被删除,无须再次删除"
      else
        flash[:error] = "出错，请联系管理员"
      end
    end
    redirect_to admin_users_path    
  end
  
  # 物理删除用户
  # DELETE /admin/users/1/rm
  # DELETE /admin/users/1/rm.xml
  def rm
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path
  end

private

  def find_user
    @user = User.find(params[:id])
  end

end
