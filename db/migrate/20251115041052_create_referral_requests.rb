class CreateReferralRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :referral_requests do |t|
      t.references :user, null: false, foreign_key: true # The requester
      t.references :referral_post, null: false, foreign_key: true

      t.text :note_to_poster # General message
      # changed to json
      t.json :submitted_data, default: {}

      # For Rails enum: status: { pending: 0, approved: 1, rejected: 2, withdrawn: 3 }
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    # Ensures a user can't request the same post multiple times
    add_index :referral_requests, [ :user_id, :referral_post_id ], unique: true
  end
end
