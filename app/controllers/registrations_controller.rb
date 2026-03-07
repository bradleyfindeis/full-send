class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    access_code = InviteCode.find_by(code: params[:access_code]&.upcase)

    if access_code.nil? || !access_code.valid_for_use?
      @user = User.new(user_params)
      flash.now[:alert] = "Invalid or expired access code."
      render :new, status: :unprocessable_entity
      return
    end

    @user = User.new(user_params)

    if @user.save
      access_code.use!
      start_new_session_for @user
      redirect_to onboarding_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
