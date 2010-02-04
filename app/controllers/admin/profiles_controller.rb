class Admin::ProfilesController < ApplicationController
  
  def index
    @profiles = Profile.all
  end
  
  def show
    @profile = Profile.find(params[:id])
  end
  
  def new
    @profile = Profile.new
  end
  
  def create
    @profile = Profile.new(params[:profile])

    if @profile.save
      flash[:notice] = '视频格式已被保存!'
      redirect_back_or_default admin_profiles_url
    else
      render :action => "new"
    end    
  end
  
  def edit
    @profile = Profile.find(params[:id])
  end
  
  def update
    @profile = Profile.find(params[:id])
    if @profile.update_attributes(params[:profile])
      flash[:notice] = '视频格式已被更新!'
      redirect_to admin_profile_path(@profile)
    else
      render edit_admin_profile_path(@profile)
    end
  end
  
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    redirect_to(admin_profiles_url)
  end
  
  
end
