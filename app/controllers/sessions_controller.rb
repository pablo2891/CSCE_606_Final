class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]
  before_action :redirect_if_logged_in, only: [ :new, :create ]

  def new
    # Renders login form, assign @user to keep state of login form
    Rails.logger.debug "SessionsController#new called"
    @user = User.new(email: params.dig(:user, :email))
  end

  def create
    user = User.find_by(email: params[:user][:email])

    if user&.authenticate(params[:user][:password])
      session[:user_id] = user.id
      redirect_to user_path(current_user), notice: "Logged in successfully!"
    else
      flash.now[:error] = "Invalid email or password"
      @user = User.new(email: params[:user][:email])
      render :new
    end
  end

  def destroy
    Rails.logger.debug "SessionsController#destroy called"
    session[:user_id] = nil
    redirect_to new_session_path, notice: "Logged out successfully!"
  end

  private

  def redirect_if_logged_in
    if current_user
      redirect_to user_path(current_user), notice: "You are already logged in!"
    end
  end
end
