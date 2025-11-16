require "rails_helper"

RSpec.describe TestMailer, type: :mailer do
  describe "#hello" do
    let(:mail) { TestMailer.hello }

    it "renders the headers" do
      expect(mail.subject).to eq("Mailtrap is working!")
      expect(mail.to).to eq([ "test@example.com" ])
      expect(mail.from).to be_present
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Hello from Mailtrap!")
    end

    it "enqueues delivery when deliver_now is called" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
