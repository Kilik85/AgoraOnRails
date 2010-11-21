class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :choose_as_spokesman
  
  def index
    @users = User.all
  end
  
  def new
   @user = User.new
   render :layout => "mini_application"
  end
  
  def create
   @user = User.new(params[:user])
   if @user.save
     flash[:notice] = "Registrado :)"
     redirect_back_or_default new_user_session_url
   else
     render :action => :new
   end
  end
  
  def show
    @user = User.find(params[:id])
    @proposals = @user.voted_proposals
  end 
  
  def choose_as_spokesman
    user = current_user
    spokesman = User.find(params[:id])
    user.spokesman = spokesman
    user.save!
    spokesman.voted_proposals.map(&:count_delegated_votes!)
    flash[:notice] = "Has elegido a tu portavoz."
    redirect_to spokesman
  end
  
  def discharge_as_spokesman
    spokesman = User.find(params[:id])
    current_user.spokesman = nil
    current_user.save!
    spokesman.voted_proposals.map(&:count_delegated_votes!)
    flash[:notice] = "Has destituido a tu portavoz."
    redirect_to spokesman
  end
  
  def publish
    fb_session = Facebooker::Session.new(ENV['FACEBOOK_PDI_APP_ID'], ENV['FACEBOOK_PDI_APP_SECRET'])
    fb_user = Facebooker::User.new(7106254, fb_session)
    fb_user.publish_to(fb_user, :message => "Hola desde AgoraOnRails")
  end
end
