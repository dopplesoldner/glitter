class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def new
    if signed_in?
      redirect_to(root_path)
    else
      @user = User.new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    if signed_in?
      redirect_to(root_path)
    else  
      @user = User.new
        @user.name = params[:user][:name]
        @user.email = params[:user][:email]
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        if @user.save
          sign_in @user
          flash[:success] = "Welcome to the Sample App!"
          redirect_to @user
        else
          render 'new'
        end
    end
  end
  
  def edit
  end
  
  def update
    @user = User.find(params[:id])
      @user.name = params[:user][:name] if !params[:user][:name].nil?
      @user.email = params[:user][:email] if !params[:user][:email].nil?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save    
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user != current_user
      @user.destroy
      flash[:success] = "User destroyed"
    end
    redirect_to users_url
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
    end
    
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in." unless signed_in?
      end
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user 
      redirect_to(root_path) unless current_user.admin?
    end
end
