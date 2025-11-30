class DashboardController < ApplicationController
  before_action :require_login

  def index
    # --- Existing Logic ---
    # Received requests (requests for posts owned by current_user)
    @received_requests = ReferralRequest.joins(:referral_post)
                                        .where(referral_posts: { user_id: current_user.id })
                                        .includes(:user, :referral_post)
                                        .order(created_at: :desc)

    # Sent requests (requests made by current_user)
    @sent_requests = current_user.referral_requests
                                 .includes(:referral_post)
                                 .order(created_at: :desc)

    # --- Filter Setup ---
    @selected_user = params[:username]
    @selected_company = params[:company_name]

    @status_options = [ "Active", "Paused", "Closed" ]
    @selected_status = params[:status]

    @date_ranges = [ "24 hours", "7 days", "30 days", "90 days", "180 days", "1 year" ]
    @selected_created_since = params[:created_since]

    @selected_job_title = params[:job_title]
    @selected_department = params[:department]

    @location_options = [ "Remote", "On-site", "Hybrid" ]
    @selected_location = params[:location]

    @job_level_options = [ "Internship", "Entry Level", "Mid Level", "Senior Level", "Management", "Executive" ]
    @selected_job_level = params[:job_level]

    @employment_type_options = [ "Full-time", "Part-time", "Contract", "Temporary", "Internship" ]
    @selected_employment_type = params[:employment_type]

    # --- Filtering Logic ---

    # 1. Initialize the query (Use includes to prevent N+1 queries if you display user/company info)
    @all_referrals = ReferralPost.all

    # 2. Filter by selected_user (Requires joining the User table)
    if @selected_user.present?
      @all_referrals = @all_referrals.joins(:user).where(users: { first_name: @selected_user })
    end

    # 3. Filter by selected_company (Using LIKE for case-insensitive partial match)
    if @selected_company.present?
      # Note: Use 'LIKE' if on SQLite/MySQL, 'LIKE' for Postgres
      @all_referrals = @all_referrals.where("company_name LIKE ?", "%#{@selected_company}%")
    end

    # 4. Filter by selected_status
    desired_status = case @selected_status
    when "Active" then :active
    when "Paused" then :paused
    when "Closed" then :closed
    else :active
    end
    @all_referrals = @all_referrals.where(status: desired_status)

    # 5. Filter by selected_created_since (Convert string options to Time objects)
    if @selected_created_since.present?
      time_threshold = case @selected_created_since
      when "24 hours" then 24.hours.ago
      when "7 days"   then 7.days.ago
      when "30 days"  then 30.days.ago
      when "90 days"  then 90.days.ago
      when "180 days" then 180.days.ago
      when "1 year"   then 1.year.ago
      end

      @all_referrals = @all_referrals.where("referral_posts.created_at >= ?", time_threshold) if time_threshold
    end

    # 6. Filter by selected_job_title (Case-insensitive partial match)
    if @selected_job_title.present?
      @all_referrals = @all_referrals.where("job_title LIKE ?", "%#{@selected_job_title}%")
    end

    # 7. Filter by selected_department
    if @selected_department.present?
      @all_referrals = @all_referrals.where("department LIKE ?", "%#{@selected_department}%")
    end

    # 8. Filter by selected_location
    if @selected_location.present?
      @all_referrals = @all_referrals.where(location: @selected_location)
    end

    # 9. Filter by selected_job_level
    if @selected_job_level.present?
      @all_referrals = @all_referrals.where(job_level: @selected_job_level)
    end

    # 10. Filter by selected_employment_type
    if @selected_employment_type.present?
      @all_referrals = @all_referrals.where(employment_type: @selected_employment_type)
    end

    # Final ordering
    @all_referrals = @all_referrals.order(created_at: :desc)
  end
end
