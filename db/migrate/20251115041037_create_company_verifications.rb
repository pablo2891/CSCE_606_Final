class CreateCompanyVerifications < ActiveRecord::Migration[7.1]
  def change
    create_table :company_verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_email, null: false
      t.string :company_name, null: false

      t.boolean :is_verified, default: false
      t.string :verification_token, index: { unique: true }
      t.datetime :verified_at

      t.timestamps
    end

    # Ensures a user can't have the same company email verified twice
    add_index :company_verifications, [ :user_id, :company_email ], unique: true
  end
end
