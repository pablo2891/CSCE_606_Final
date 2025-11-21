class ReferralRequestsController < ApplicationController
  before_action :require_login
  before_action :set_referral_post, only: %i[create create_from_message]
  before_action :set_referral_request, only: %i[update_status]

  # Standard create when a user applies via the post page
  def create
    # submitted_data may come as a JSON string or as params hash (e.g. { "q1" => "answer", ...})
    submitted_payload = normalize_submitted_data(params[:submitted_data] || params[:referral_request]&.fetch(:submitted_data, nil))

    @referral_request = @referral_post.referral_requests.build(
      user: current_user,
      status: :pending,
      submitted_data: submitted_payload
    )

    if @referral_request.save
      redirect_to referral_post_path(@referral_post), notice: "Request sent!"
    else
      # uniqueness failure or other validation fail
      flash[:alert] = "Failed to send request."
      redirect_to referral_post_path(@referral_post)
    end
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

  # PATCH /referral_requests/:id/status
  # Expects param: status => 'approved' or 'rejected' (or 'pending')
  def update_status
    # authorize: only allow the owner of the post to update the request status
    unless @referral_request.referral_post.user == current_user
      head :forbidden and return
    end

    new_status = params[:status]
    if %w[pending approved rejected withdrawn].include?(new_status)
      @referral_request.update(status: new_status)
      redirect_back fallback_location: dashboard_path, notice: "Request status updated."
    else
      redirect_back fallback_location: dashboard_path, alert: "Invalid status"
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
