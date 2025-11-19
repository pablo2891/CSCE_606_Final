class RedirectController < ApplicationController
  # Catch-all redirect action
  def fallback
    if logged_in?
      redirect_to user_path(current_user), notice: "Redirected to your profile."
    else
      redirect_to new_session_path, alert: "Page not found. Please log in."
    end
  end
end
