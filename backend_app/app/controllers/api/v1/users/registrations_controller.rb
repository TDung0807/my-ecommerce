module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        skip_before_action :authorize_request, only: :create
        respond_to :json

        def create
          build_resource(sign_up_params)

          resource.save
          if resource.persisted?
            sign_in(resource_name, resource, store: false) 
            respond_with resource
          else
            clean_up_passwords resource
            set_minimum_password_length
            respond_with resource
          end
        rescue ActiveRecord::RecordNotUnique => e
          render json: { message: 'Email already taken', error: e.message }, status: :unprocessable_entity
        end


        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              message: 'Signed up successfully',
              user: resource
            }, status: :ok
          else
            render json: {
              message: 'Sign up failed',
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
