class DashboardController < ApplicationController
  before_action :require_login

  def index
    # Received requests (requests for posts owned by current_user)
    @received_requests = ReferralRequest.joins(:referral_post)
                                        .where(referral_posts: { user_id: current_user.id })
                                        .includes(:user, :referral_post)
                                        .order(created_at: :desc)

    # Sent requests (requests made by current_user)
    @sent_requests = current_user.referral_requests.includes(:referral_post).order(created_at: :desc)
  end
end
