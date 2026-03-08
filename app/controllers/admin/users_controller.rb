module Admin
  class UsersController < BaseController
    def index
      @users = User.order(total_points: :desc)
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])

      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot delete yourself"
      else
        @user.destroy
        redirect_to admin_users_path, notice: "User deleted"
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email_address, :admin)
    end
  end
end
