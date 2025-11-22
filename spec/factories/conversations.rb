FactoryBot.define do
  factory :conversation do
    sender { nil }
    recipient { nil }
    subject { "MyString" }
  end
end
