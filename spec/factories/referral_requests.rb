FactoryBot.define do
  factory :referral_request do
    association :user
    association :referral_post
    status { :pending }
    submitted_data { { "answer" => "I'm interested" } }
  end
end
