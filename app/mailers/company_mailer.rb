class CompanyMailer < ApplicationMailer
  # Sends the verification email to the company work email
  def company_verification_email
    @verification = params[:verification]
    # Link to CompanyVerificationsController#verify: /company_verifications/:id/verify?token=...
    @url = verify_company_verification_url(@verification, token: @verification.verification_token)

    mail(to: @verification.company_email, subject: "Verify your #{@verification.company_name} Email")
  end
end
