module Api
  module V1
    module Users
      class PasswordsController < ApplicationController
        before_action :authorize_request, only: :update
        respond_to :json

        # POST /api/v1/users/forgot_password
        # body: { email: "user@example.com" }
        def forgot
          # No mailer — just simulate
          if params[:email].present?
            user = User.find_by(email: params[:email])
            if user
              # Normally: user.send_reset_password_instructions
              render json: { message: "Password reset instructions sent successfully." }, status: :ok
            else
              # Still return success to prevent email enumeration
              render json: { message: "Password reset instructions sent successfully." }, status: :ok
            end
          else
            render json: { error: "Email is required" }, status: :bad_request
          end
        end

        # POST /api/v1/users/reset_password
        # body: { password: "...", password_confirmation: "..." }
        def reset
          # Here we skip token validation & just update password directly
          # In real app you'd verify reset_password_token
          user = User.find_by(email: params[:email])
          if user && user.update(password: params[:password],
                                 password_confirmation: params[:password_confirmation])
            render json: { message: "Password reset successfully." }, status: :ok
          else
            render json: { errors: user ? user.errors.full_messages : ["User not found"] },
                   status: :unprocessable_entity
          end
        end

        # POST /api/v1/users/change_password  (JWT required)
        # body: { user: { current_password: "...", password: "...", password_confirmation: "..." } }
        def update
          u = current_user

          unless u&.valid_password?(change_password_params[:current_password])
            return render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
          end

          if u.update(password: change_password_params[:password],
                      password_confirmation: change_password_params[:password_confirmation])
            render json: { message: "Password updated successfully" }, status: :ok
          else
            render json: { errors: u.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def change_password_params
          params.require(:user).permit(:current_password, :password, :password_confirmation)
        end
      end
    end
  end
end
