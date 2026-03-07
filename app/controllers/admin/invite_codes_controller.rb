module Admin
  class InviteCodesController < BaseController
    def index
      @invite_codes = InviteCode.order(created_at: :desc)
    end

    def create
      @invite_code = InviteCode.new(
        code: params[:code].presence,
        max_uses: params[:max_uses] || 1,
        expires_at: params[:expires_at].presence,
        created_by: current_user
      )

      if @invite_code.save
        redirect_to admin_invite_codes_path, notice: "Access code created: #{@invite_code.code}"
      else
        redirect_to admin_invite_codes_path, alert: "Failed to create access code: #{@invite_code.errors.full_messages.join(', ')}"
      end
    end

    def destroy
      @invite_code = InviteCode.find(params[:id])
      @invite_code.destroy
      redirect_to admin_invite_codes_path, notice: "Access code deleted"
    end
  end
end
