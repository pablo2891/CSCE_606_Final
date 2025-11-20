require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#company_match?" do
    it "returns true for identical strings" do
      expect(helper.company_match?("Google", "Google")).to be true
    end

    it "returns true for case-insensitive match" do
      expect(helper.company_match?("google", "Google")).to be true
    end

    it "returns true for strings with different whitespace" do
      expect(helper.company_match?("  Google  ", "Google")).to be true
    end

    it "returns false for different strings" do
      expect(helper.company_match?("Google", "Apple")).to be false
    end
  end

  describe "#verification_status_for" do
    let(:verified_cv) { double("CompanyVerification", is_verified: true) }
    let(:pending_cv) { double("CompanyVerification", is_verified: false) }
    let(:verifications) do
      {
        "google" => verified_cv,
        "apple" => pending_cv
      }
    end

    it "returns :verified for verified company" do
      expect(helper.verification_status_for(verifications, "Google")).to eq(:verified)
    end

    it "returns :pending for unverified company" do
      expect(helper.verification_status_for(verifications, "Apple")).to eq(:pending)
    end

    it "returns :none for unknown company" do
      expect(helper.verification_status_for(verifications, "Microsoft")).to eq(:none)
    end
  end
end
