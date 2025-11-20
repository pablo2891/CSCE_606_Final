module CompanyVerificationsHelper
    # :nocov: pure view formatting helper excluded from coverage
    def company_name_to_domain(company_name)
        cleaned_name = company_name.downcase
                                                            .strip
                                                            .gsub(/\s+/, "")
                                                            .gsub(/[^a-z0-9]/, "")
        "#{cleaned_name}.com"
    end
  # :nocov:
end
