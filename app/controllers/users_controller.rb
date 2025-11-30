class UsersController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]
  before_action :redirect_if_logged_in, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to user_path(current_user), notice: "Account created successfully!"
    else
      # Collect all errors and display as flash alert
      flash.now[:error] = @user.errors.full_messages.join(", ")
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    @user_verifications = @user.company_verifications.index_by { |cv| cv.company_name.downcase.strip }
    @verified_companies = @user.company_verifications.where(is_verified: true)

  rescue ActiveRecord::RecordNotFound
    redirect_to user_path(current_user), alert: "User not found."
  end

  def edit
    @user = User.find(params[:id])
    # Only allow current_user to edit their own profile
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
  end

  def update
    @user = User.find(params[:id])
    @old_password = params[:user][:old_password]
    @new_password = params[:user][:password]

    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user

    if params[:remove_resume] == "1"
      @user.resume.purge_later
    end

    if (!@new_password.blank? && @old_password.blank?) || (!@old_password.blank? && !@user.authenticate(@old_password))
      flash.now[:error] = "Old password is incorrect"
      render :edit
      return
    end

    if @user.update(user_params)
      redirect_to @user, notice: "Profile updated successfully!"
    else
      render :edit
    end
  end

  # Experience
  def add_experience
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @experience = {} # placeholder for form
  end

  def create_experience
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user

    exp = params.require(:experience).permit(:title, :company, :start_date, :end_date, :description).to_h

    parsed_start = Date.parse(exp["start_date"]) rescue nil
    parsed_end   = (Date.parse(exp["end_date"])  rescue nil) || Date.today
    date_valid  = parsed_start.nil? || (parsed_start <= Date.today && parsed_end <= Date.today && parsed_start < parsed_end)

    if exp["title"].blank? || exp["company"].blank? || !date_valid
      flash.now[:error] = "Failed to add experience."
      render :add_experience
      return
    end

    @user.experiences_data << exp
    if @user.save
      redirect_to user_path(@user), notice: "Experience added!"
    else
      flash.now[:error] = "Failed to add experience."
      render :add_experience
    end
  end

  def edit_experience
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i
    @experience = @user.experiences_data[@index]
  end

  def update_experience
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i

    updated_exp = params.require(:experience).permit(:title, :company, :start_date, :end_date, :description).to_h
    parsed_start = Date.parse(updated_exp["start_date"]) rescue nil
    parsed_end   = (Date.parse(updated_exp["end_date"])  rescue nil) || Date.today
    date_valid  = parsed_start.nil? || (parsed_start <= Date.today && parsed_end <= Date.today && parsed_start < parsed_end)
    @user.experiences_data[@index] = updated_exp

    if @user.save && date_valid
      redirect_to user_path(@user), notice: "Experience updated successfully!"
    else
      flash.now[:error] = @user.errors.full_messages.join(", ")
      @experience = @user.experiences_data[@index]
      render :edit_experience
    end
  end

  def delete_experience
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i

    @user.experiences_data.delete_at(@index)
    if @user.save
      redirect_to user_path(@user), notice: "Experience entry deleted."
    else
      redirect_to user_path(@user), alert: "Failed to delete experience entry."
    end
  end

  # Education
  def add_education
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @education = {}
  end

  def create_education
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user

    edu = params.require(:education).permit(:degree, :school, :start_date, :end_date, :description).to_h

    parsed_start = Date.parse(edu["start_date"]) rescue nil
    parsed_end   = (Date.parse(edu["end_date"])  rescue nil) || Date.today
    date_valid  = parsed_start.nil? || (parsed_start <= Date.today && parsed_start < parsed_end)

    # Require degree and school for now; start_date is optional in the UI/tests
    if edu["degree"].blank? || edu["school"].blank? || !date_valid
      flash.now[:error] = "Failed to add education."
      render :add_education
      return
    end

    @user.educations_data << edu
    if @user.save
      redirect_to user_path(@user), notice: "Education added!"
    else
      flash.now[:error] = "Failed to add education."
      render :add_education
    end
  end

  def edit_education
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i
    @education = @user.educations_data[@index]
  end

  def update_education
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i

    updated_edu = params.require(:education).permit(:degree, :school, :start_date, :end_date, :description).to_h
    parsed_start = Date.parse(updated_edu["start_date"]) rescue nil
    parsed_end   = (Date.parse(updated_edu["end_date"])  rescue nil) || Date.today
    date_valid  = parsed_start.nil? || (parsed_start <= Date.today && parsed_start < parsed_end)
    @user.educations_data[@index] = updated_edu

    if @user.save && date_valid
      redirect_to user_path(@user), notice: "Education updated successfully!"
    else
      flash.now[:error] = @user.errors.full_messages.join(", ")
      @education = @user.educations_data[@index]
      render :edit_education
    end
  end

  def delete_education
    @user = User.find(params[:id])
    return redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i

    @user.educations_data.delete_at(@index)
    if @user.save
      redirect_to user_path(@user), notice: "Education entry deleted."
    else
      redirect_to user_path(@user), alert: "Failed to delete education entry."
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name,
      :headline, :summary, :resume_url,
      :linkedin_url, :github_url, :resume
    )
  end
end
