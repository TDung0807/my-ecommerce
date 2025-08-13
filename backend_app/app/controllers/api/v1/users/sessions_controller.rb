module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        skip_before_action :authorize_request, only: :create
        respond_to :json

        def create
          # Find user by email
          user = User.find_by(email: sign_in_params[:email])

          # Check if user exists and password is valid
          if user&.valid_password?(sign_in_params[:password])
            # Generate JWT token without signing in
            token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
            render json: {
              message: 'Logged in successfully',
              token: token[0]
            }, status: :ok
          else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
          end
        end

        private

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        def respond_to_on_destroy
          render json: { message: 'Logged out.' }, status: :ok
        end
      end
    end
  end
end