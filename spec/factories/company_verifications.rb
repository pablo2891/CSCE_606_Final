FactoryBot.define do
  factory :company_verification do
    association :user
    company_name { "Tech Corp" }
    company_email { "engineer@techcorp.com" }
    is_verified { true }
  end
end
