class OnboardingController < ApplicationController
  def show
    @user = current_user
    redirect_to root_path if @user.onboarding_completed?
  end

  def update
    @user = current_user
    if @user.update(onboarding_params.merge(onboarding_completed: true))
      redirect_to new_season_prediction_path, notice: "Welcome to Full Send! Now lock in your season champion predictions."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def onboarding_params
    params.require(:user).permit(:timezone, :time_format, :theme)
  end
end
