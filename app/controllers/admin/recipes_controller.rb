class Admin::RecipesController < ApplicationController
  
  def index
    @recipes = Recipe.all
  end
  
  def show
    @recipe = Recipe.find(params[:id])
  end
  
  def new
    @recipe = Recipe.new
  end
  
  def create
    @recipe = Recipe.new(params[:recipe])

    if @recipe.save
      flash[:notice] = '视频格式已被保存!'
      redirect_back_or_default admin_recipes_url
    else
      render :action => "new"
    end    
  end
  
  def edit
    @recipe = Recipe.find(params[:id])
  end
  
  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update_attributes(params[:recipe])
      flash[:notice] = '视频格式已被更新!'
      redirect_to admin_recipe_path(@recipe)
    else
      render edit_admin_recipe_path(@recipe)
    end
  end
  
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy

    redirect_to(admin_recipes_url)
  end
  
  
end
