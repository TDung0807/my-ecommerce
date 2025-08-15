module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      def index
        cached_users = $redis.get("users:all")
        if cached_users
          users = JSON.parse(cached_users)
        else
          users = User.all.as_json(only: %i[id email name])
          $redis.set("users:all", users.to_json) if users.present?
        end

        render json: users || [], status: :ok
      end

      # GET /api/v1/users/:id
      def show
        cache_key = "users:#{params[:id]}"

        if (cached = $redis.get(cache_key))
          user_data = JSON.parse(cached)
        else
          @user = User.find_by(id: params[:id])
          unless @user
            return render json: { errors: ['User not found'] }, status: :not_found
          end

          user_data = @user.as_json(only: %i[id email name], methods: %i[updated_at])
          $redis.set(cache_key, user_data.to_json, ex: 12.hours.to_i)
        end

        render json: user_data, status: :ok
      end

      # POST /api/v1/users
      def create
        user = User.new(user_params)
        if user.save
          RedisCache::Users.new.cache_on_register(user)
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          RedisCache::Users.new.update(@user)
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        if @user.destroy
          RedisCache::Users.new.delete(@user.id)
          head :no_content
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find_by(id: params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
