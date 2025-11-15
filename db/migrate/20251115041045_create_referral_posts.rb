class CreateReferralPosts < ActiveRecord::Migration[7.1]
  def change
    create_table :referral_posts do |t|
      t.references :user, null: false, foreign_key: true # The poster

      # The "proof" that the user is verified with this company
      t.references :company_verification, null: false, foreign_key: true

      # Denormalized for easy searching
      t.string :company_name, null: false, index: true

      t.string :title, null: false
      t.text :description

      t.text :job_openings_links

      # For Rails enum: status: { active: 0, paused: 1, closed: 2 }
      t.integer :status, default: 0, null: false

      t.jsonb :additional_criteria, default: {}
      t.jsonb :request_criteria, default: {}

      t.timestamps
    end
  end
end
