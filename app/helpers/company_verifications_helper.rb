module CompanyVerificationsHelper
    def company_name_to_domain(company_name)
        cleaned_name = company_name.downcase
                                    .strip
                                    .gsub(/\s+/, "")       # remove spaces
                                    .gsub(/[^a-z0-9]/, "") # remove special chars
        "#{cleaned_name}.com"
    end
end
