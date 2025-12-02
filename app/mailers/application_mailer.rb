class ApplicationMailer < ActionMailer::Base
  default from: "LinkedOut <#{ENV.fetch("MAILER_FROM_EMAIL", "no-reply@linkedout.local")}>"
  layout "mailer"
end
