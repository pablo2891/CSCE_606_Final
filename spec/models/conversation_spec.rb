require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let!(:user1) do
    User.create!(
      email: "user1@tamu.edu",
      password: "password",
      password_confirmation: "password",
      first_name: "User",
      last_name: "One"
    )
  end

  let!(:user2) do
    User.create!(
      email: "user2@tamu.edu",
      password: "password",
      password_confirmation: "password",
      first_name: "User",
      last_name: "Two"
    )
  end

  describe "associations" do
    it "belongs to sender" do
      conversation = Conversation.create!(sender: user1, recipient: user2)
      expect(conversation.sender).to eq(user1)
    end

    it "belongs to recipient" do
      conversation = Conversation.create!(sender: user1, recipient: user2)
      expect(conversation.recipient).to eq(user2)
    end

    it "has many messages" do
      conversation = Conversation.create!(sender: user1, recipient: user2)
      message1 = Message.create!(conversation: conversation, user: user1, body: "Hello")
      message2 = Message.create!(conversation: conversation, user: user2, body: "Hi")

      expect(conversation.messages).to include(message1, message2)
      expect(conversation.messages.count).to eq(2)
    end

    it "destroys dependent messages when conversation is deleted" do
      conversation = Conversation.create!(sender: user1, recipient: user2)
      Message.create!(conversation: conversation, user: user1, body: "Test")

      expect {
        conversation.destroy
      }.to change(Message, :count).by(-1)
    end
  end

  describe "#other_user" do
    let(:conversation) { Conversation.create!(sender: user1, recipient: user2) }

    it "returns recipient when user is sender" do
      expect(conversation.other_user(user1)).to eq(user2)
    end

    it "returns sender when user is recipient" do
      expect(conversation.other_user(user2)).to eq(user1)
    end

    it "returns recipient when given sender" do
      other = conversation.other_user(user1)
      expect(other).to eq(user2)
      expect(other.id).to eq(user2.id)
    end

    it "returns sender when given recipient" do
      other = conversation.other_user(user2)
      expect(other).to eq(user1)
      expect(other.id).to eq(user1.id)
    end
  end

  describe ".between" do
    let!(:conversation) { Conversation.create!(sender: user1, recipient: user2, subject: "Test") }

    it "finds conversation where user_a is sender and user_b is recipient" do
      result = Conversation.between(user1.id, user2.id)
      expect(result).to eq(conversation)
    end

    it "finds conversation where user_a is recipient and user_b is sender" do
      result = Conversation.between(user2.id, user1.id)
      expect(result).to eq(conversation)
    end

    it "returns nil when no conversation exists" do
      user3 = User.create!(email: "user3@tamu.edu", password: "password", password_confirmation: "password")
      result = Conversation.between(user1.id, user3.id)
      expect(result).to be_nil
    end

    it "limits result to 1" do
      # Even if somehow there were multiple conversations, only return one
      result = Conversation.between(user1.id, user2.id)
      expect(result).to be_a(Conversation)
    end

    it "returns first conversation if multiple exist" do
      # Create another conversation in reverse direction
      conv2 = Conversation.create!(sender: user2, recipient: user1, subject: "Another")

      result = Conversation.between(user1.id, user2.id)
      expect([ conversation, conv2 ]).to include(result)
    end
  end

  describe ".find_or_create_between" do
    it "creates new conversation when none exists" do
      user3 = User.create!(email: "user3@tamu.edu", password: "password", password_confirmation: "password")

      expect {
        Conversation.find_or_create_between(user1, user3, subject: "New Chat")
      }.to change(Conversation, :count).by(1)

      conv = Conversation.last
      expect(conv.sender).to eq(user1)
      expect(conv.recipient).to eq(user3)
      expect(conv.subject).to eq("New Chat")
    end

    it "returns existing conversation when one exists" do
      existing = Conversation.create!(sender: user1, recipient: user2, subject: "Existing")

      expect {
        result = Conversation.find_or_create_between(user1, user2, subject: "Should not create")
        expect(result).to eq(existing)
      }.not_to change(Conversation, :count)
    end

    it "finds conversation regardless of sender/recipient order" do
      existing = Conversation.create!(sender: user1, recipient: user2)

      result = Conversation.find_or_create_between(user2, user1)
      expect(result).to eq(existing)
    end

    it "creates conversation with nil subject if not provided" do
      user3 = User.create!(email: "user3@tamu.edu", password: "password", password_confirmation: "password")

      conv = Conversation.find_or_create_between(user1, user3)
      expect(conv.subject).to be_nil
      expect(conv).to be_persisted
    end

    it "reuses existing conversation even when called in reverse order" do
      existing = Conversation.create!(sender: user1, recipient: user2, subject: "Original")

      result = Conversation.find_or_create_between(user2, user1, subject: "Reversed")
      expect(result).to eq(existing)
      expect(result.subject).to eq("Original") # Subject not updated
    end
  end

  describe "subject attribute" do
    it "can be nil" do
      conversation = Conversation.create!(sender: user1, recipient: user2)
      expect(conversation.subject).to be_nil
      expect(conversation).to be_valid
    end

    it "can be set to a string" do
      conversation = Conversation.create!(sender: user1, recipient: user2, subject: "Test Subject")
      expect(conversation.subject).to eq("Test Subject")
    end
  end

  describe "validations" do
    it "requires sender" do
      conversation = Conversation.new(recipient: user2)
      expect(conversation).not_to be_valid
    end

    it "requires recipient" do
      conversation = Conversation.new(sender: user1)
      expect(conversation).not_to be_valid
    end

    it "is valid with sender and recipient" do
      conversation = Conversation.new(sender: user1, recipient: user2)
      expect(conversation).to be_valid
    end
  end
end
