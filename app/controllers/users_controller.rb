class UsersController < ApplicationController

  before_filter :require_user, :only => [:show, :edit, :update]	
	
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
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

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = @current_user
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = 'Account Registered!'
      redirect_back_or_default account_url
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = @current_user
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Account updated!'
        redirect_to account_url
      else
        render :action => "edit"
      end
  end
  
end
