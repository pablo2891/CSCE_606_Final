class UserMailer < ApplicationMailer
  # Sends the verification email to the user's TAMU address
  def tamu_verification_email
    @user = params[:user]
    # This builds the link: http://localhost:3000/verify_tamu?token=...
    @url  = verify_tamu_url(token: @user.tamu_verification_token)

    mail(to: @user.email, subject: "Verify your TAMU Email for LinkedOut")
  end
end
