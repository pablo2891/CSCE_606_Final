class CompanyVerificationsController < ApplicationController
  before_action :set_company_verification, only: %i[ show edit ]

  # GET /company_verifications/1 or /company_verifications/1.json
  def show
  end

  # GET /company_verifications/new
  def new
    @company_verification = CompanyVerification.new
  end

  # POST /company_verifications or /company_verifications.json
  def create
    @company_verification = CompanyVerification.find_by(user_id: session[:user_id])

    respond_to do |format|
      if @company_verification.verification_token == company_verification_params[:verification_token]
        @company_verification.company_name  = company_verification_params[:company_name]
        @company_verification.company_email = company_verification_params[:company_email]
        @company_verification.is_verified   = true
        @company_verification.verified_at   = Time.current
        format.html { redirect_to @company_verification, notice: "Company verification was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_verification
      @company_verification = CompanyVerification.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def company_verification_params
      params.expect(company_verification: [ :company_email, :company_name ])
    end
end
