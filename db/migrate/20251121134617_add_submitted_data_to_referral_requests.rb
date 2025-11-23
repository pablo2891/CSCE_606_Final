class AddSubmittedDataToReferralRequests < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:referral_requests, :submitted_data)
      add_column :referral_requests, :submitted_data, :json
    end
  end
end
