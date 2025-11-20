class ReferralRequestsController < ApplicationController
  before_action :require_login

  def create
    @referral_post = ReferralPost.find(params[:referral_post_id])
    @referral_request = @referral_post.referral_requests.build(user: current_user, status: :pending)

    if @referral_request.save
      redirect_to referral_posts_path, notice: "Request sent!"
    else
      redirect_to referral_posts_path, alert: "Failed to send request."
    end
  end
end
