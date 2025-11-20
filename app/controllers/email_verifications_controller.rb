class EmailVerificationsController < ApplicationController
  # Skip login check for verification links, as users might click them from email without being logged in
  skip_before_action :require_login, only: [ :verify_tamu, :verify_company ]

  def verify_tamu
    user = User.find_by(tamu_verification_token: params[:token])

    if user
      user.update!(is_tamu_verified: true, tamu_verified_at: Time.current)
      flash[:success] = "Your TAMU email has been successfully verified!"
    else
      flash[:error] = "Invalid or expired verification link."
    end

    redirect_to root_path
  end

  def verify_company
    verification = CompanyVerification.find_by(verification_token: params[:token])

    if verification
      verification.update!(is_verified: true, verified_at: Time.current)
      flash[:success] = "Company email has been successfully verified!"
    else
      flash[:error] = "Invalid or expired verification link."
    end

    if current_user
      redirect_to user_path(current_user)
    else
      redirect_to root_path
    end
  end
end
