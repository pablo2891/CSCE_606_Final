class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true

  after_create :touch_conversation

  private

  def touch_conversation
    conversation.touch
  end
end
