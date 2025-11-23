FactoryBot.define do
  factory :referral_post do
    association :user
    association :company_verification
    title { "Software Engineer Position" }
    job_title { "Software Engineer" }
    company_name { "Tech Corp" }
    status { :active }
    department { "Engineering" }
    location { "Remote" }
    questions { [] }
  end
end
