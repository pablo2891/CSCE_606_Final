class RedirectController < ApplicationController
  # Catch-all redirect action
  def fallback
    if logged_in?
      redirect_to user_path(current_user), notice: "Redirected to your profile."
    end
    # :nocov: end wrapper excluded from coverage accounting
  end # :nocov:
end
