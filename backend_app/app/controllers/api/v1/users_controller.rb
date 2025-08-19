module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      def index
        users = nil
        if (cached_users = $redis.get("users:all"))
          parsed = JSON.parse(cached_users) rescue []
          db_ids = User.pluck(:id)
          if parsed.any? { |u| !db_ids.include?(u["id"]) }
            users = User.all
            $redis.set("users:all", users.to_json)
          else
            users = parsed
          end
        else
          users = User.all
          $redis.set("users:all", users.to_json)
        end

        render json: users
      end

      # GET /api/v1/users/:id
      def show
        render json: @user
      end

      # POST /api/v1/users
      def create
        user = User.new(user_params)
        if user.save
          # clear cache so index is fresh
          $redis.del("users:all")
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          $redis.del("users:all")
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        $redis.del("users:all")
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :password, :name, :phone_number)
      end
    end
  end
end
