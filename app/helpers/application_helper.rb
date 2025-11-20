module ApplicationHelper
  def company_match?(company_name_1, company_name_2)
    normalize = ->(s) { s.to_s.downcase.gsub(/\s+/, "") }
    normalize.call(company_name_1) == normalize.call(company_name_2)
  end

  def verification_status_for(user_verifications, company_name)
    cv = user_verifications[company_name.to_s.downcase.strip]
    return :none unless cv
    return :verified if cv.is_verified
    :pending
  end
end
