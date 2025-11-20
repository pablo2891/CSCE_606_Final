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
    @user.reload

    @user_verifications = current_user.company_verifications.index_by { |cv| cv.company_name.downcase.strip }
    @verified_companies = current_user.company_verifications.where(is_verified: true)

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
    if @user.update(user_params)
      redirect_to @user, notice: "Profile updated successfully!"
    else
      render :edit
    end
  end

  # Experience
  def add_experience
    @user = User.find(params[:id])
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @experience = {} # placeholder for form
  end

  def create_experience
    @user = User.find(params[:id])
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user

    exp = params.require(:experience).permit(:title, :company, :start_date, :end_date, :description).to_h
    
    if exp["title"].blank? || exp["company"].blank? || exp["start_date"].blank?
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
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i
    @experience = @user.experiences_data[@index]
  end

  def update_experience
    @user = User.find(params[:id])
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i

    updated_exp = params.require(:experience).permit(:title, :company, :start_date, :end_date, :description).to_h
    @user.experiences_data[@index] = updated_exp
    @user.save!

    redirect_to user_path(@user), notice: "Experience updated successfully!"
  end


  # Education
  def add_education
    @user = User.find(params[:id])
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @education = {}
  end

  def create_education
    @user = User.find(params[:id])
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user

    edu = params.require(:education).permit(:degree, :school, :start_date, :end_date, :description).to_h
    
    if edu["degree"].blank? || edu["school"].blank? || edu["start_date"].blank?
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
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i
    @education = @user.educations_data[@index]
  end

  def update_education
    @user = User.find(params[:id])
    redirect_to user_path(@user), alert: "Unauthorized" unless current_user == @user
    @index = params[:index].to_i

    updated_edu = params.require(:education).permit(:degree, :school, :start_date, :end_date, :description).to_h
    @user.educations_data[@index] = updated_edu
    @user.save!

    redirect_to user_path(@user), notice: "Education updated successfully!"
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name,
      :headline, :summary, :resume_url,
      :linkedin_url, :github_url
    )
  end
end
