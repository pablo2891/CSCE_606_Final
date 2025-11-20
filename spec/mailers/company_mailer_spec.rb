require "rails_helper"

RSpec.describe CompanyMailer, type: :mailer do
  it "builds the company verification email with correct recipient, subject, and link" do
    user = User.create!(email: "user@tamu.edu", password: "secret1", password_confirmation: "secret1")
    verification = CompanyVerification.create!(
      user: user,
      company_email: "jane@acme.com",
      company_name: "Acme",
      verification_token: "tok123"
    )

    mail = described_class.with(verification: verification).company_verification_email

    expect(mail.to).to eq([ verification.company_email ])
    expect(mail.subject).to include("Verify your #{verification.company_name} Email")
    expected_path = Rails.application.routes.url_helpers.verify_company_verification_path(verification, token: verification.verification_token)
    expect(mail.body.encoded).to include(expected_path)
  end
end
