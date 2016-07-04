class UsersController < ApplicationController

  layout :choose_layout

  def new
    @user = User.new
  end

  def create
    logout_keeping_session!
    @user = User.new(user_params)
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
    respond_to do |format|
      format.html
    end
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html {
          if @user.needs_to_authenticate_lastfm?
            redirect_to lastfm_url(:action => :authenticate)
          else
            redirect_to home_url
          end
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    @user = current_user
    @user.spotify_hash = spotify_user.to_hash
    @user.save!
    redirect_to edit_user_url(@user)
    flash[:notice] = "Spotify account succesfully authenticated!"
  end

  private

  def choose_layout
    if ["new", "create"].include?(params[:action])
      "login"
    else
      "application"
    end
  end

  def user_params
    params.require(:user).permit(
      :login, :name, :nickname, :email,
      :lastfm_name, :password, :password_confirmation
    )
  end
end
