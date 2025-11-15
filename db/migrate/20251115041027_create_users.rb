class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      # --- Core Auth ---
      t.string :email, null: false, index: { unique: true } # TAMU Email
      t.string :password_digest # For has_secure_password
      t.string :first_name
      t.string :last_name

      # --- TAMU Verification ---
      t.boolean :is_tamu_verified, default: false
      t.string :tamu_verification_token, index: { unique: true }
      t.datetime :tamu_verified_at

      # --- Profile (Merged) ---
      t.string :headline
      t.text :summary
      t.string :resume_url
      t.string :linkedin_url
      t.string :github_url

      # --- Merged Experiences & Educations ---
      t.jsonb :experiences_data, null: false, default: []
      t.jsonb :educations_data, null: false, default: []

      t.timestamps
    end
  end
end
