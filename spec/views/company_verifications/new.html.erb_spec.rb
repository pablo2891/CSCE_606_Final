require 'rails_helper'

RSpec.describe "company_verifications/new", type: :view do
  before do
    User.destroy_all
    CompanyVerification.destroy_all
  end

  let!(:user1) do
    User.create!(email: "john.smith@tamu.edu",
                 first_name: "John",
                 last_name: "Smith",
                 password: "12346789")
  end

  let!(:user2) do
    User.create!(email: "alice.yi@tamu.edu",
                 first_name: "Alice",
                 last_name: "Yi",
                 password: "12346789")
  end

  let!(:user3) do
    User.create!(email: "shawn.han@tamu.edu",
                 first_name: "Shawn",
                 last_name: "Han",
                 password: "123456789")
  end


  it "renders new company_verification form" do
    render
    session[:user_id] = user1.id

    assert_select "form[action=?][method=?]", company_verifications_path, "post" do
      assert_select "input[name=?]", "company_verification[company_email]"

      assert_select "input[name=?]", "company_verification[company_name]"

      assert_select "input[name=?]", "company_verification[verification_token]"
    end
  end
end
