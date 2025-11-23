class AddFieldsToReferralPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :referral_posts, :job_title, :string
    add_column :referral_posts, :department, :string
    add_column :referral_posts, :location, :string
    add_column :referral_posts, :job_level, :string
    add_column :referral_posts, :employment_type, :string
    add_column :referral_posts, :why_referring, :text
    add_column :referral_posts, :questions, :json
  end
end
