class ReferralPostsController < ApplicationController
  before_action :require_login
  before_action :set_referral_post, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @referral_posts = ReferralPost.active_posts
  end

  def new
    @referral_post = ReferralPost.new
  end

  def show
    # public view of a single post
  end

  def create
    # We need to find the verification for the selected company
    company_name = params.dig(:referral_post, :company_name)
    # Find the verification for this user and company
    verification = current_user.company_verifications.find_by(company_name: company_name, is_verified: true)

    @referral_post = current_user.referral_posts.build(referral_post_params)
    @referral_post.company_verification = verification
    @referral_post.status = :active

    # Ensure questions is an array (empty if none)
    if params[:referral_post][:questions].present?
      # Expect questions as an array of strings from the form
      @referral_post.questions = Array(params[:referral_post][:questions]).map(&:to_s).reject(&:blank?)
    end

    if verification.blank?
      flash.now[:error] = "You must pick one of your verified companies."
      render :new and return
    end

    if @referral_post.save
      redirect_to referral_post_path(@referral_post), notice: "Referral post created!"
    else
      flash.now[:error] = @referral_post.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
  end

  def update
    if params[:referral_post][:questions].present?
      params[:referral_post][:questions] = Array(params[:referral_post][:questions]).map(&:to_s).reject(&:blank?)
    end

    if @referral_post.update(referral_post_params)
      redirect_to referral_post_path(@referral_post), notice: "Referral post updated!"
    else
      flash.now[:error] = @referral_post.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    @referral_post.destroy
    redirect_to referral_posts_path, notice: "Referral post deleted."
  end

  private

  def set_referral_post
    @referral_post = ReferralPost.find(params[:id])
  end

  def authorize_owner!
    unless @referral_post.user == current_user
      redirect_to referral_posts_path, alert: "Unauthorized"
    end
  end

  def referral_post_params
    params.require(:referral_post).permit(
      :title,
      :company_name,
      :job_title,
      :department,
      :location,
      :job_level,
      :employment_type,
      :why_referring,
      questions: [] # permit array
    )
  end

  def handle_not_found
    flash[:alert] = "Referral post may have been removed or you may not have access."
    redirect_to dashboard_path
  end
end
