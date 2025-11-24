class RemoveResumeUrlFromUsers < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:users, :resume_url)
      remove_column :users, :resume_url, :string
    end
  end
end
