Given("a referral request exists with nil submitted_data") do
  user = FactoryBot.create(:user)
  cv = user.company_verifications.create!(
    company_name: "Test Co",
    company_email: "test@testco.com",
    is_verified: true
  )
  post = ReferralPost.create!(
    user: user,
    company_verification: cv,
    title: "Test Job",
    job_title: "Engineer",
    company_name: "Test Co",
    status: :active
  )

  @referral_request = ReferralRequest.create!(
    user: user,
    referral_post: post,
    status: :pending,
    submitted_data: nil
  )
end

Given("a referral request exists with submitted_data") do
  user = FactoryBot.create(:user)
  cv = user.company_verifications.create!(
    company_name: "Test Co",
    company_email: "test@testco.com",
    is_verified: true
  )
  post = ReferralPost.create!(
    user: user,
    company_verification: cv,
    title: "Test Job",
    job_title: "Engineer",
    company_name: "Test Co",
    status: :active
  )

  @referral_request = ReferralRequest.create!(
    user: user,
    referral_post: post,
    status: :pending,
    submitted_data: { "answer" => "test answer", "experience" => "5 years" }
  )
end

When("I call submitted_data_hash") do
  @result = @referral_request.submitted_data_hash
end

Then("it should return an empty hash") do
  expect(@result).to eq({})
end

Then("it should return the correct hash") do
  expect(@result).to eq({ "answer" => "test answer", "experience" => "5 years" })
end
