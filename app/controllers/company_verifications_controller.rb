class CompanyVerificationsController < ApplicationController
  def new
    @company_verification = CompanyVerification.new
    @company_verification.company_name = params[:company_name] if params[:company_name].present?
  end

  def create
    @company_verification = current_user.company_verifications.build(company_verification_params)

    unless domain_matches_company?(@company_verification)
      flash.now[:error] = "Your email domain must match the company name."
      render :new and return
    end

    if @company_verification.save
      # flash[:error] = "Cannot send verification email at this time. Please try again later."
      # redirect_to user_path(current_user) and return
      #   CompanyVerificationMailer.verify_email(@company_verification).deliver_later

      ### SEND EMAIL HERE + REDIRECT ###
      redirect_to company_verifications_path, notice: "A verification email has been sent to your company email."
    else
      # puts @company_verification.errors.full_messages
      flash[:error] = "Failed to create company verification."
      redirect_to user_path(current_user) and return
    end
  end

  def verify
    # localhost:3000/company_verifications/<id>/verify?id=<>&token=<>
    verification = CompanyVerification.find(params[:id])

    if verification.verification_token == params[:token]
      verification.update(is_verified: true, verified_at: Time.current)
      redirect_to company_verifications_path, notice: "Company email successfully verified!"
    else
      redirect_to root_path, alert: "Invalid or expired verification link."
    end
  end

  def index
    # Get all verifications for current user
    all_verifications = current_user.company_verifications.order(created_at: :desc)

    # Separate verified vs pending
    @verified_verifications = all_verifications.select(&:is_verified)
    @pending_verifications  = all_verifications.reject(&:is_verified)
  end

  def destroy
    @company_verification = current_user.company_verifications.find(params[:id])
    @company_verification.destroy
    redirect_to company_verifications_path, notice: "Verification request deleted."
  end

  private

  def company_verification_params
    params.require(:company_verification).permit(:company_name, :company_email)
  end

  def domain_matches_company?(verification)
    email_domain = verification.company_email.split("@").last.downcase
    company_domain = verification.company_name.parameterize.gsub("-", "")
    email_domain.include?(company_domain)
  end
end
