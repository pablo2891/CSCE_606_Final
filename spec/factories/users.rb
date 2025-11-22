FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@tamu.edu" }
    first_name { "Test" }
    last_name { "User" }
    password { "password123" }
    password_confirmation { "password123" }
    experiences_data { [] }
    educations_data { [] }
  end
end
