class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update, :index, :destroy, :following, :followers]
  before_filter :correct_user, only: [:edit, :update, :following, :followers]
  before_filter :is_admin, only: :destroy
  def new
  	@user = User.new
  end
  def index
    search_term = params[:search]
    page = params[:page]
    @users = search_term.nil? ? User.paginate(page: page) : User.search_by_experience(search_term).paginate(page: page)
  end
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  def edit
  end
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Nivter!"
      redirect_to @user
    else
      render 'new'
    end
  end
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end
  def following
    @title = "Following"
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  def followers
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  private
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end
  def correct_user
  	@user = User.find(params[:id])
    redirect_to root_path if @user != current_user
  end
  def is_admin
    if !current_user.admin? || params[:id] == current_user.id.to_s
      redirect_to(root_path)
    end
  end
end
