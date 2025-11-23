require 'rails_helper'

RSpec.describe "Messaging Integration", type: :request do
  let!(:alice) do
    User.create!(
      email: "alice@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Alice",
      last_name: "Smith"
    )
  end

  let!(:bob) do
    User.create!(
      email: "bob@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Bob",
      last_name: "Jones"
    )
  end

  describe "Complete messaging workflow" do
    it "allows users to have a full conversation" do
      # Step 1: Alice logs in
      post session_path, params: { user: { email: alice.email, password: "password123" } }
      expect(response).to redirect_to(user_path(alice))

      # Step 2: Alice starts a conversation with Bob
      expect {
        post conversations_path, params: {
          recipient_id: bob.id,
          subject: "About the referral",
          body: "Hi Bob, I saw your referral post!"
        }
      }.to change(Conversation, :count).by(1)
        .and change(Message, :count).by(1)

      conversation = Conversation.last
      expect(conversation.sender).to eq(alice)
      expect(conversation.recipient).to eq(bob)
      expect(conversation.messages.first.body).to eq("Hi Bob, I saw your referral post!")

      # Step 3: Alice views the conversation
      get conversation_path(conversation)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Hi Bob, I saw your referral post!")

      # Step 4: Bob logs in
      delete session_path
      post session_path, params: { user: { email: bob.email, password: "password123" } }

      # Step 5: Bob sees the conversation in his list
      get conversations_path
      expect(response.body).to include("Alice Smith")

      # Step 6: Bob opens the conversation - messages marked as read
      message = conversation.messages.first
      expect(message.read).to eq(false)

      get conversation_path(conversation)

      message.reload
      expect(message.read).to eq(true)

      # Step 7: Bob replies
      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "Hi Alice! Let me tell you about it." }
        }
      }.to change(Message, :count).by(1)

      expect(conversation.messages.last.body).to eq("Hi Alice! Let me tell you about it.")
      expect(conversation.messages.last.user).to eq(bob)

      # Step 8: Alice logs back in and sees Bob's reply
      delete session_path
      post session_path, params: { user: { email: alice.email, password: "password123" } }

      get conversation_path(conversation)
      expect(response.body).to include("Hi Alice! Let me tell you about it.")

      # Step 9: Alice sends another message
      post conversation_messages_path(conversation), params: {
        message: { body: "Great! Can you provide more details?" }
      }

      expect(conversation.messages.count).to eq(3)

      # Step 10: Bob can delete the conversation
      delete session_path
      post session_path, params: { user: { email: bob.email, password: "password123" } }

      expect {
        delete conversation_path(conversation)
      }.to change(Conversation, :count).by(-1)

      expect(response).to redirect_to(conversations_path)
    end
  end

  describe "Conversation reuse" do
    it "reuses existing conversation instead of creating duplicate" do
      # Alice creates first conversation
      post session_path, params: { user: { email: alice.email, password: "password123" } }

      post conversations_path, params: {
        recipient_id: bob.id,
        subject: "First conversation",
        body: "Hello"
      }

      first_conv = Conversation.last

      # Alice tries to create another conversation with Bob
      expect {
        post conversations_path, params: {
          recipient_id: bob.id,
          subject: "Second attempt",
          body: "Another message"
        }
      }.not_to change(Conversation, :count)

      # Should redirect to existing conversation
      expect(response).to redirect_to(conversation_path(first_conv))
    end
  end

  describe "Authorization enforcement" do
    let(:charlie) do
      User.create!(
        email: "charlie@tamu.edu",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    it "prevents unauthorized users from viewing conversations" do
      # Alice and Bob have a conversation
      post session_path, params: { user: { email: alice.email, password: "password123" } }
      post conversations_path, params: { recipient_id: bob.id, subject: "Private", body: "Secret" }
      conversation = Conversation.last

      # Charlie tries to access it
      delete session_path
      post session_path, params: { user: { email: charlie.email, password: "password123" } }

      get conversation_path(conversation)
      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:alert]).to eq("Unauthorized")
    end

    it "prevents unauthorized users from sending messages" do
      # Alice and Bob have a conversation
      post session_path, params: { user: { email: alice.email, password: "password123" } }
      post conversations_path, params: { recipient_id: bob.id, subject: "Private" }
      conversation = Conversation.last

      # Charlie tries to send a message
      delete session_path
      post session_path, params: { user: { email: charlie.email, password: "password123" } }

      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "I shouldn't be here" }
        }
      }.not_to change(Message, :count)

      expect(response).to redirect_to(conversations_path)
    end

    it "prevents unauthorized users from deleting conversations" do
      # Alice and Bob have a conversation
      post session_path, params: { user: { email: alice.email, password: "password123" } }
      post conversations_path, params: { recipient_id: bob.id, subject: "Private" }
      conversation = Conversation.last

      # Charlie tries to delete it
      delete session_path
      post session_path, params: { user: { email: charlie.email, password: "password123" } }

      expect {
        delete conversation_path(conversation)
      }.not_to change(Conversation, :count)

      expect(response).to redirect_to(conversations_path)
    end
  end

  describe "Message validation" do
    it "does not create message with blank body" do
      post session_path, params: { user: { email: alice.email, password: "password123" } }
      post conversations_path, params: { recipient_id: bob.id, subject: "Test" }
      conversation = Conversation.last

      expect {
        post conversation_messages_path(conversation), params: {
          message: { body: "" }
        }
      }.not_to change(Message, :count)

      expect(response).to render_template("conversations/show")
      # Verify the form is re-rendered with errors
      expect(response.body).to include("message_body")
    end
  end

  describe "Conversation ordering" do
    it "displays most recently updated conversations first" do
      post session_path, params: { user: { email: alice.email, password: "password123" } }

      # Create first conversation
      post conversations_path, params: { recipient_id: bob.id, subject: "Old" }
      old_conv = Conversation.last
      old_conv.update(updated_at: 2.hours.ago)

      # Create second conversation with another user
      charlie = User.create!(email: "charlie@tamu.edu", password: "password123", password_confirmation: "password123")
      post conversations_path, params: { recipient_id: charlie.id, subject: "New" }

      # Get conversations page
      get conversations_path

      # New conversation should appear before old one
      expect(response.body.index("New")).to be < response.body.index("Old")
    end
  end
end
