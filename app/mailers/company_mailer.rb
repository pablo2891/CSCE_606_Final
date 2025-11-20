class CompanyMailer < ApplicationMailer
  def verify_company(verification_entry)
    @current_user = verification_entry.user
    @company_email = verification_entry.company_email
    @company_name  = verification_entry.company_name
    @verification_link = company_verifications_valify_path(id: verification_entry.id, token: verification_entry.verification_token)
    puts "DEBUG: Verification link - #{@verification_link}"
    mail(to: verification_entry.company_email, subject: "Verify Your Email for #{verification_entry.company_name}!")
  end
end