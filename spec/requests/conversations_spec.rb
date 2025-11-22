require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  let!(:user1) do
    User.create!(
      email: "user1@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "User",
      last_name: "One"
    )
  end

  let!(:user2) do
    User.create!(
      email: "user2@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "User",
      last_name: "Two"
    )
  end

  let!(:conversation) do
    Conversation.create!(
      sender: user1,
      recipient: user2,
      subject: "Test Conversation"
    )
  end

  let!(:message) do
    Message.create!(
      conversation: conversation,
      user: user2,
      body: "Hello from user2",
      read: false
    )
  end

  before do
    # Login as user1
    post session_path, params: { user: { email: user1.email, password: "password123" } }
  end

  describe "GET /conversations" do
    it "displays all conversations for current user" do
      get conversations_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Conversations")
      expect(response.body).to include("User Two")
    end

    it "includes conversations where user is sender" do
      get conversations_path
      expect(response.body).to include(conversation.subject)
    end

    it "includes conversations where user is recipient" do
      conv2 = Conversation.create!(sender: user2, recipient: user1, subject: "Another chat")
      get conversations_path
      expect(response.body).to include("Another chat")
    end

    it "orders conversations by updated_at descending" do
      old_conv = Conversation.create!(sender: user1, recipient: user2, subject: "Old")
      old_conv.update(updated_at: 1.day.ago)

      new_conv = Conversation.create!(sender: user1, recipient: user2, subject: "New")

      get conversations_path
      # New conversation should appear before old one in the list
      expect(response.body.index("New")).to be < response.body.index("Old")
    end
  end

  describe "GET /conversations/:id" do
    it "displays the conversation and messages" do
      get conversation_path(conversation)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(conversation.subject)
      expect(response.body).to include("Hello from user2")
    end

    it "marks unread messages as read for current user" do
      expect(message.read).to eq(false)

      get conversation_path(conversation)

      message.reload
      expect(message.read).to eq(true)
    end

    it "does not mark own messages as read" do
      own_message = Message.create!(
        conversation: conversation,
        user: user1,
        body: "My message",
        read: false
      )

      get conversation_path(conversation)

      own_message.reload
      expect(own_message.read).to eq(false)
    end

    it "redirects unauthorized user with alert" do
      user3 = User.create!(
        email: "user3@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      # Login as user3
      delete session_path
      post session_path, params: { user: { email: user3.email, password: "password123" } }

      get conversation_path(conversation)
      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:alert]).to eq("Unauthorized")
    end

    it "orders messages by created_at ascending" do
      msg1 = Message.create!(conversation: conversation, user: user1, body: "First", created_at: 1.hour.ago)
      msg2 = Message.create!(conversation: conversation, user: user2, body: "Second", created_at: 30.minutes.ago)
      msg3 = Message.create!(conversation: conversation, user: user1, body: "Third", created_at: 1.minute.ago)

      get conversation_path(conversation)

      # Messages should appear in chronological order
      expect(response.body.index("First")).to be < response.body.index("Second")
      expect(response.body.index("Second")).to be < response.body.index("Third")
    end
  end

describe "POST /conversations" do
    it "creates a new conversation with subject and initial message" do
      user3 = User.create!(
        email: "user3@tamu.edu",
        password: "password123",
        password_confirmation: "password123",
        first_name: "User",
        last_name: "Three"
      )

      expect {
        post conversations_path, params: {
          recipient_id: user3.id,
          subject: "New Conversation",
          body: "Initial message"
        }
      }.to change(Conversation, :count).by(1)
        .and change(Message, :count).by(1)

      new_conv = Conversation.last
      expect(new_conv.subject).to eq("New Conversation")
      expect(new_conv.sender).to eq(user1)
      expect(new_conv.recipient).to eq(user3)
      expect(response).to redirect_to(conversation_path(new_conv))
    end

    it "creates initial message if body is present" do
      user3 = User.create!(
        email: "user3@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      post conversations_path, params: {
        recipient_id: user3.id,
        subject: "With Message",
        body: "Hello there"
      }

      new_conv = Conversation.last
      expect(new_conv.messages.count).to eq(1)
      expect(new_conv.messages.last.body).to eq("Hello there")
      expect(new_conv.messages.last.user).to eq(user1)
    end

    it "does not create message if body is blank" do
      user3 = User.create!(
        email: "user3@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      expect {
        post conversations_path, params: {
          recipient_id: user3.id,
          subject: "No Message"
        }
      }.to change(Message, :count).by(0)
    end

    it "finds existing conversation between same users" do
      # Create existing conversation between user1 and user2
      existing = Conversation.find_or_create_between(user1, user2, subject: "Existing")

      # Try to create another conversation with same users
      post conversations_path, params: {
        recipient_id: user2.id,
        subject: "Should reuse existing"
      }

      # Should redirect to existing conversation
      expect(response).to redirect_to(conversation_path(existing))
    end

    it "redirects to the conversation after creation" do
      user3 = User.create!(
        email: "user3@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      post conversations_path, params: {
        recipient_id: user3.id,
        subject: "Redirect test"
      }

      expect(response).to redirect_to(conversation_path(Conversation.last))
    end
  end

  describe "DELETE /conversations/:id" do
    it "deletes the conversation as sender" do
      expect {
        delete conversation_path(conversation)
      }.to change(Conversation, :count).by(-1)

      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:notice]).to eq("Conversation deleted")
    end

    it "deletes the conversation as recipient" do
      # Login as user2
      delete session_path
      post session_path, params: { user: { email: user2.email, password: "password123" } }

      expect {
        delete conversation_path(conversation)
      }.to change(Conversation, :count).by(-1)

      expect(response).to redirect_to(conversations_path)
    end

    it "prevents unauthorized deletion" do
      user3 = User.create!(
        email: "user3@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      # Login as user3
      delete session_path
      post session_path, params: { user: { email: user3.email, password: "password123" } }

      expect {
        delete conversation_path(conversation)
      }.not_to change(Conversation, :count)

      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:alert]).to eq("Unauthorized")
    end
  end
end
