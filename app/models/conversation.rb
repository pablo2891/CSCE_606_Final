class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  has_many :messages, dependent: :destroy

  def other_user(user)
    user == sender ? recipient : sender
  end

  def self.between(user_a_id, user_b_id)
    where("(sender_id = :a AND recipient_id = :b) OR (sender_id = :b AND recipient_id = :a)",
          a: user_a_id, b: user_b_id).limit(1).first
  end

  def self.find_or_create_between(user_a, user_b, subject: nil)
    existing = between(user_a.id, user_b.id)
    return existing if existing.present?
    create!(sender: user_a, recipient: user_b, subject: subject)
  end
end
