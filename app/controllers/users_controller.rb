class UsersController < ApplicationController
  before_filter :signed_in_user,
                only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy

  def index
    #@users = User.paginate(page: params[:page])
    if params[:search]
      @users = User.search(params[:search]).order("created_at DESC")
      flash[:notice] = "Search Returned Following Users"
    else
      @users = User.order("created_at DESC")
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Chatter!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile Updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User Information Deleted"
    redirect_to root_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end


  def search
    search = params["search_terms"]
    if search.blank? then
      flash[:notice] = "Invalid Search Term"
      redirect_to users_path
    else
      all_results = User::search(search)
      if all_results.empty? then
        flash[:notice] = "No matching users were found on Chatter"
        redirect_to users_path
      else
        @search_results = all_results
        @search_term = search
        flash[:notice] = "Search found the following results"
      end
    end
  end




  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end