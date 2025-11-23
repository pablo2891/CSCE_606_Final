require 'rails_helper'

RSpec.describe "Messages", type: :request do
  let!(:user1) do
    User.create!(
      email: "sender@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Sender",
      last_name: "User"
    )
  end

  let!(:user2) do
    User.create!(
      email: "receiver@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Receiver",
      last_name: "User"
    )
  end

  let!(:conversation) do
    Conversation.create!(
      sender: user1,
      recipient: user2,
      subject: "Test Messages"
    )
  end

  before do
    # Login as user1
    post session_path, params: { user: { email: user1.email, password: "password123" } }
  end

  describe "POST /conversations/:conversation_id/messages" do
    it "creates a new message successfully" do
      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "Hello, this is a test message" }
        }
      }.to change(Message, :count).by(1)

      expect(response).to redirect_to(conversation_path(conversation))
      follow_redirect!
      expect(flash[:notice]).to eq("Message sent.")
    end

    it "associates message with current user" do
      post conversation_messages_path(conversation), params: {
        message: { body: "My message" }
      }

      message = Message.last
      expect(message.user).to eq(user1)
      expect(message.conversation).to eq(conversation)
    end

    it "associates message with the conversation" do
      post conversation_messages_path(conversation), params: {
        message: { body: "Test body" }
      }

      expect(conversation.messages.last.body).to eq("Test body")
    end

    it "renders conversation show with alert on failure" do
      # Trigger validation failure by not providing body
      post conversation_messages_path(conversation), params: {
        message: { body: "" }
      }

      expect(response).to have_http_status(:success)
      expect(response).to render_template("conversations/show")
      # The message won't be created due to validation
      expect(Message.where(body: "").count).to eq(0)
    end

    it "does not create message with blank body" do
      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "" }
        }
      }.not_to change(Message, :count)
    end

    it "redirects unauthorized user" do
      user3 = User.create!(
        email: "other@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      # Login as user3 (not part of conversation)
      delete session_path
      post session_path, params: { user: { email: user3.email, password: "password123" } }

      post conversation_messages_path(conversation), params: {
        message: { body: "Unauthorized message" }
      }

      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:alert]).to eq("Unauthorized")
    end

    it "allows recipient to send messages" do
      # Login as user2 (recipient)
      delete session_path
      post session_path, params: { user: { email: user2.email, password: "password123" } }

      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "Reply from recipient" }
        }
      }.to change(Message, :count).by(1)

      expect(Message.last.user).to eq(user2)
    end

    it "updates conversation timestamp when message is created" do
      conversation.update(updated_at: 1.hour.ago)
      old_time = conversation.updated_at

      # Wait a bit to ensure timestamp changes
      sleep(0.1)

      post conversation_messages_path(conversation), params: {
        message: { body: "Update timestamp" }
      }

      conversation.reload
      expect(conversation.updated_at).to be > old_time
    end

    it "sets message as unread by default" do
      post conversation_messages_path(conversation), params: {
        message: { body: "Unread message" }
      }

      message = Message.last
      expect(message.read).to eq(false)
    end
  end

  describe "authorization checks" do
    it "blocks user not in conversation from creating message" do
      user3 = User.create!(
        email: "outsider@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )

      delete session_path
      post session_path, params: { user: { email: user3.email, password: "password123" } }

      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "Should be blocked" }
        }
      }.not_to change(Message, :count)
    end

    it "allows sender to create messages" do
      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "From sender" }
        }
      }.to change(Message, :count).by(1)
    end

    it "allows recipient to create messages" do
      delete session_path
      post session_path, params: { user: { email: user2.email, password: "password123" } }

      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "From recipient" }
        }
      }.to change(Message, :count).by(1)
    end
  end
end
