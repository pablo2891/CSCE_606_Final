class ReferralPostsController < ApplicationController
  before_action :require_login

  def index
    @referral_posts = ReferralPost.active_posts
  end

  def new
    @referral_post = ReferralPost.new
  end

  def create
    # We need to find the verification for the selected company
    company_name = params[:referral_post][:company_name]
    # Find the verification for this user and company
    verification = current_user.company_verifications.find_by(company_name: company_name, is_verified: true)

    @referral_post = current_user.referral_posts.build(referral_post_params)
    @referral_post.company_verification = verification
    @referral_post.status = :active

    if @referral_post.save
      redirect_to referral_posts_path, notice: "Referral post created!"
    else
      flash.now[:error] = @referral_post.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def referral_post_params
    params.require(:referral_post).permit(:title, :company_name)
  end
end
