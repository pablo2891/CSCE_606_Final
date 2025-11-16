# This initializer attempts two things:
# 1) Set OpenSSL's SSLContext default params to not verify peer certificates.
# 2) Ensure Action Mailer uses an 'openssl_verify_mode' of 'none' for SMTP.

begin
  require "openssl"

  if defined?(OpenSSL::SSL::SSLContext) && OpenSSL::SSL::SSLContext.const_defined?(:DEFAULT_PARAMS)
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.merge!(verify_mode: OpenSSL::SSL::VERIFY_NONE)
  end
rescue => e
  warn "disable_global_ssl_verification: failed to configure OpenSSL defaults: #{e.class}: #{e.message}"
end

# Also apply to ActionMailer SMTP settings so mail delivery libraries honor it.
begin
  if defined?(ActionMailer::Base)
    ActionMailer::Base.smtp_settings ||= {}
    ActionMailer::Base.smtp_settings[:openssl_verify_mode] = "none"
  end
rescue => e
  warn "disable_global_ssl_verification: failed to set ActionMailer smtp_settings: #{e.class}: #{e.message}"
end
