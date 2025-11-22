class ReferralRequestsController < ApplicationController
  before_action :require_login
  before_action :set_referral_post, only: %i[create create_from_message]
  before_action :set_referral_request, only: %i[update_status]

  def create
    submitted_payload = normalize_submitted_data(params[:submitted_data] || params[:referral_request]&.fetch(:submitted_data, nil))

    # Prevent applying to closed posts
    if @referral_post.closed?
      flash[:alert] = "This post is closed and no longer accepting requests."
      redirect_to referral_post_path(@referral_post) and return
    end

    @referral_request = @referral_post.referral_requests.build(
      user: current_user,
      status: :pending,
      submitted_data: submitted_payload
    )

    if @referral_request.save
      redirect_to referral_post_path(@referral_post), notice: "Request sent!"
    else
      flash[:alert] = "Failed to send request."
      redirect_to referral_post_path(@referral_post)
    end
  end

  def update_status
    # authorize: only allow the owner of the post to update the request status
    unless @referral_request.referral_post.user == current_user
      head :forbidden and return
    end

    new_status = params[:status]
    if %w[pending approved rejected withdrawn].include?(new_status)
      ActiveRecord::Base.transaction do
        @referral_request.update!(status: new_status)

        if new_status == "approved"
          # Close the post to stop further requests
          post = @referral_request.referral_post
          post.update!(status: :closed)

          # Create or find conversation between post owner (current_user) and requester
          requester = @referral_request.user
          conversation = Conversation.find_or_create_between(current_user, requester, subject: "Referral for: #{post.title}")

          # Create a message notifying the requester
          conversation.messages.create!(
            user: current_user,
            body: "Your referral request for '#{post.title}' has been approved by #{current_user.full_name}."
          )
        end
      end

      redirect_back fallback_location: dashboard_path, notice: "Request status updated."
    else
      redirect_back fallback_location: dashboard_path, alert: "Invalid status"
    end

  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: dashboard_path, alert: "Failed to update status: #{e.message}"
  end

  # Endpoint to be called by messaging system (when a message referencing a post is sent)
  # It creates a ReferralRequest on behalf of the message sender (current_user).
  # POST /referral_posts/:referral_post_id/referral_requests/from_message
  def create_from_message
    submitted_payload = normalize_submitted_data(params[:submitted_data])
    @referral_request = @referral_post.referral_requests.build(
      user: current_user,
      status: :pending,
      submitted_data: submitted_payload
    )

    if @referral_request.save
      # Return a minimal JSON payload for the messaging system to consume (or redirect)
      render json: { success: true, referral_request_id: @referral_request.id, redirect_to: dashboard_path }, status: :created
    else
      render json: { success: false, errors: @referral_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_referral_post
    @referral_post = ReferralPost.find(params[:referral_post_id])
  end

  def set_referral_request
    @referral_request = ReferralRequest.find(params[:id])
  end

  def normalize_submitted_data(raw)
    # Accept JSON string, hash, or nil. Return a normalized Hash.
    return {} if raw.blank?
    if raw.is_a?(String)
      begin
        parsed = JSON.parse(raw)
        parsed.is_a?(Hash) ? parsed : { answers: parsed }
      rescue JSON::ParserError
        # treat as single answer string
        { "answer" => raw }
      end
    elsif raw.is_a?(ActionController::Parameters) || raw.is_a?(Hash)
      raw.to_unsafe_h
    else
      { "value" => raw }
    end
  end
end
