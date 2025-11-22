require 'rails_helper'

RSpec.describe Message, type: :model do
  let!(:user1) do
    User.create!(
      email: "msg_user1@tamu.edu",
      password: "password",
      password_confirmation: "password",
      first_name: "Message",
      last_name: "User1"
    )
  end

  let!(:user2) do
    User.create!(
      email: "msg_user2@tamu.edu",
      password: "password",
      password_confirmation: "password",
      first_name: "Message",
      last_name: "User2"
    )
  end

  let!(:conversation) do
    Conversation.create!(sender: user1, recipient: user2, subject: "Test Chat")
  end

  describe "associations" do
    it "belongs to conversation" do
      message = Message.create!(conversation: conversation, user: user1, body: "Test")
      expect(message.conversation).to eq(conversation)
    end

    it "belongs to user" do
      message = Message.create!(conversation: conversation, user: user1, body: "Test")
      expect(message.user).to eq(user1)
    end
  end

  describe "validations" do
    it "requires body to be present" do
      message = Message.new(conversation: conversation, user: user1, body: "")
      expect(message).not_to be_valid
      expect(message.errors[:body]).to include("can't be blank")
    end

    it "is valid with body" do
      message = Message.new(conversation: conversation, user: user1, body: "Valid message")
      expect(message).to be_valid
    end

    it "requires conversation" do
      message = Message.new(user: user1, body: "Test")
      expect(message).not_to be_valid
    end

    it "requires user" do
      message = Message.new(conversation: conversation, body: "Test")
      expect(message).not_to be_valid
    end
  end

  describe "callbacks" do
    describe "after_create :touch_conversation" do
      it "updates conversation's updated_at timestamp when message is created" do
        conversation.update(updated_at: 1.hour.ago)
        old_timestamp = conversation.updated_at

        # Wait a tiny bit to ensure timestamp difference
        sleep(0.01)

        Message.create!(conversation: conversation, user: user1, body: "New message")

        conversation.reload
        expect(conversation.updated_at).to be > old_timestamp
      end

      it "touches conversation even for messages from different users" do
        conversation.update(updated_at: 1.hour.ago)
        old_timestamp = conversation.updated_at

        sleep(0.01)

        Message.create!(conversation: conversation, user: user2, body: "Message from user2")

        conversation.reload
        expect(conversation.updated_at).to be > old_timestamp
      end

      it "updates timestamp for each message" do
        conversation.update(updated_at: 2.hours.ago)

        Message.create!(conversation: conversation, user: user1, body: "First")
        first_update = conversation.reload.updated_at

        sleep(0.01)

        Message.create!(conversation: conversation, user: user2, body: "Second")
        second_update = conversation.reload.updated_at

        expect(second_update).to be > first_update
      end
    end
  end

  describe "default values" do
    it "defaults read to false" do
      message = Message.create!(conversation: conversation, user: user1, body: "Unread")
      expect(message.read).to eq(false)
    end

    it "can be explicitly set to true" do
      message = Message.create!(conversation: conversation, user: user1, body: "Read", read: true)
      expect(message.read).to eq(true)
    end
  end

  describe "body content" do
    it "stores text body correctly" do
      message = Message.create!(conversation: conversation, user: user1, body: "Hello world")
      expect(message.body).to eq("Hello world")
    end

    it "accepts long text" do
      long_text = "A" * 1000
      message = Message.create!(conversation: conversation, user: user1, body: long_text)
      expect(message.body.length).to eq(1000)
    end

    it "preserves whitespace and newlines" do
      text_with_formatting = "Line 1\n\nLine 2\n  Indented"
      message = Message.create!(conversation: conversation, user: user1, body: text_with_formatting)
      expect(message.body).to eq(text_with_formatting)
    end
  end

  describe "read status" do
    it "can be updated from false to true" do
      message = Message.create!(conversation: conversation, user: user1, body: "Test", read: false)
      expect(message.read).to eq(false)

      message.update!(read: true)
      expect(message.read).to eq(true)
    end

    it "supports mass update of read status" do
      msg1 = Message.create!(conversation: conversation, user: user1, body: "Msg1", read: false)
      msg2 = Message.create!(conversation: conversation, user: user1, body: "Msg2", read: false)

      Message.where(id: [ msg1.id, msg2.id ]).update_all(read: true)

      expect(msg1.reload.read).to eq(true)
      expect(msg2.reload.read).to eq(true)
    end
  end

  describe "message ordering" do
    it "can be ordered by created_at" do
      msg1 = Message.create!(conversation: conversation, user: user1, body: "First", created_at: 3.hours.ago)
      msg2 = Message.create!(conversation: conversation, user: user2, body: "Second", created_at: 2.hours.ago)
      msg3 = Message.create!(conversation: conversation, user: user1, body: "Third", created_at: 1.hour.ago)

      ordered = Message.where(conversation: conversation).order(created_at: :asc)
      expect(ordered.pluck(:body)).to eq([ "First", "Second", "Third" ])
    end
  end

  describe "filtering messages" do
    it "can filter by conversation" do
      conv2 = Conversation.create!(sender: user1, recipient: user2)

      msg1 = Message.create!(conversation: conversation, user: user1, body: "Conv1")
      msg2 = Message.create!(conversation: conv2, user: user1, body: "Conv2")

      conv1_messages = Message.where(conversation: conversation)
      expect(conv1_messages).to include(msg1)
      expect(conv1_messages).not_to include(msg2)
    end

    it "can filter by user" do
      msg1 = Message.create!(conversation: conversation, user: user1, body: "From User1")
      msg2 = Message.create!(conversation: conversation, user: user2, body: "From User2")

      user1_messages = Message.where(user: user1)
      expect(user1_messages).to include(msg1)
      expect(user1_messages).not_to include(msg2)
    end

    it "can filter by read status" do
      msg1 = Message.create!(conversation: conversation, user: user1, body: "Read", read: true)
      msg2 = Message.create!(conversation: conversation, user: user2, body: "Unread", read: false)

      unread = Message.where(read: false)
      expect(unread).to include(msg2)
      expect(unread).not_to include(msg1)
    end
  end

  describe "deletion" do
    it "can be deleted independently" do
      message = Message.create!(conversation: conversation, user: user1, body: "Delete me")

      expect {
        message.destroy
      }.to change(Message, :count).by(-1)

      # Conversation should still exist
      expect(Conversation.exists?(conversation.id)).to eq(true)
    end

    it "is deleted when conversation is destroyed" do
      message = Message.create!(conversation: conversation, user: user1, body: "Will be deleted")

      expect {
        conversation.destroy
      }.to change(Message, :count).by(-1)
    end
  end
end
