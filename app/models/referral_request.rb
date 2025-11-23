class ReferralRequest < ApplicationRecord
  # --- 1. Table Relationships ---
  # This is a join table between a User (the requester) and a Post.
  belongs_to :user # The user who is *making* the request
  belongs_to :referral_post

  # --- 2. Enums (for the 'status' integer column) ---
  # Gives you helper methods like `request.pending?` or `request.approve!`
  enum :status, { pending: 0, approved: 1, rejected: 2, withdrawn: 3 }

  # --- 3. Validations ---
  # This is a critical business rule:
  # It ensures a user can only make ONE request per post.
  validates :user_id, uniqueness: { scope: :referral_post_id, message: "You have already sent a request for this post" }

  # submitted_data is jsonb so we can store arbitrary question->answer map
  # convenience: return Hash with string keys
  def submitted_data_hash
    submitted_data || {}
  end
end
