require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  it "builds the TAMU verification email with correct recipient, subject, and link" do
    user = User.create!(email: "aggie@tamu.edu", password: "secret1", password_confirmation: "secret1", tamu_verification_token: "abc123")

    mail = described_class.with(user: user).tamu_verification_email

    expect(mail.to).to eq([ user.email ])
    expect(mail.subject).to include("Verify your TAMU Email")
    expected_path = Rails.application.routes.url_helpers.verify_tamu_path(token: user.tamu_verification_token)
    expect(mail.body.encoded).to include(expected_path)
  end
end
