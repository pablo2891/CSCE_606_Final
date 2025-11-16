class TestMailer < ApplicationMailer
  def hello
    mail(to: "test@example.com", subject: "Mailtrap is working!")
  end
end
