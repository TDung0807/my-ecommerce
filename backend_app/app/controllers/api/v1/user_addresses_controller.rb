module Api
  module V1
    class UserAddressesController < ApplicationController
      # Uncomment if you have auth helpers
      # before_action :authenticate_api_user!

      before_action :set_user,         only: [:index, :create, :default]
      before_action :set_user_address, only: [:show, :update, :destroy, :make_default]
      before_action :normalize_is_default_enum, only: [:create, :update]
      before_action :authorize_ownership!

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not found" }, status: :not_found
      end

      # GET /api/v1/users/:user_id/user_addresses
      def index
        user_addresses = @user.user_addresses.includes(:address).order(id: :desc)
        render json: user_addresses.as_json(include: :address)
      end

      # POST /api/v1/users/:user_id/user_addresses
      def create
        ActiveRecord::Base.transaction do
          ua = @user.user_addresses.new

          # assign simple attributes first (string 'true'/'false' already normalized)
          ua.is_default = user_address_params[:is_default]
          ua.address_id = user_address_params[:address_id] if user_address_params[:address_id].present?

          # build nested address, and attach the user if Address belongs_to :user
          if (addr_attrs = user_address_params[:address_attributes]).present?
            ua.build_address(addr_attrs)
            ua.address.user = @user if ua.address.respond_to?(:user=) # only if Address belongs_to :user
          end

          # optional debug AFTER building nested address so validations make sense
          Rails.logger.info("ua attrs: #{ua.attributes.inspect}")
          Rails.logger.info("ua.address attrs: #{ua.address&.attributes.inspect}")

          ua.save!

          if ua.is_default == 'true' || @user.user_addresses.where(is_default: 'true').where.not(id: ua.id).empty?
            ensure_single_default!(@user, ua)
          end

          render json: ua.as_json(include: :address), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        # show the real failing model's errors (could be Address or UserAddress)
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end



      # GET /api/v1/user_addresses/:id
      def show
        render json: @user_address.as_json(include: :address)
      end

      # PATCH/PUT /api/v1/user_addresses/:id
      def update
        ActiveRecord::Base.transaction do
          @user_address.update!(user_address_params)
          if @user_address.is_default == 'true'
            ensure_single_default!(@user_address.user, @user_address)
          end
        end

        render json: @user_address.as_json(include: :address)
      rescue ActiveRecord::RecordInvalid
        render json: { errors: @user_address.errors.full_messages }, status: :unprocessable_entity
      end

      # DELETE /api/v1/user_addresses/:id
      def destroy
        user = @user_address.user
        was_default = (@user_address.is_default == 'true')
        @user_address.destroy!

        # If default was removed, promote oldest remaining
        if was_default
          next_one = user.user_addresses.order(id: :asc).first
          next_one&.update(is_default: 'true')
        end

        head :no_content
      end

      # GET /api/v1/users/:user_id/user_addresses/default
      def default
        ua = @user.user_addresses.includes(:address).find_by(is_default: 'true')
        render json: ua&.as_json(include: :address)
      end

      # PATCH /api/v1/user_addresses/:id/make_default
      def make_default
        ActiveRecord::Base.transaction do
          ensure_single_default!(@user_address.user, @user_address)
        end
        render json: @user_address.as_json(include: :address)
      end

      private

      # Strong params
      def user_address_params
        params.require(:user_address).permit(
          :is_default,
          :address_id,
          address_attributes: [
            :unit_number,
            :street_number,
            :address_line,
            :region,
            :city_id,
            :country_id
          ]
        )
      end

      # Normalize boolean-ish values to "true"/"false" (Postgres enum)
      def normalize_is_default_enum
        v = params.dig(:user_address, :is_default)
        return if v.nil?
        params[:user_address][:is_default] =
          case v
          when true, 'true', '1', 1 then 'true'
          when false, 'false', '0', 0, '' then 'false'
          else v
          end
      end

      # Guarantee only one default per user
      def ensure_single_default!(user, make_default_ua)
        UserAddress.where(user_id: user.id).update_all(is_default: 'false')
        make_default_ua.update!(is_default: 'true')
      end

      # ---- Finders ----
      def set_user
        @user = User.find(params[:user_id])
      end

      def set_user_address
        @user_address = UserAddress.includes(:address, :user).find(params[:id])
      end

      # ---- Authorization ----
      def authorize_ownership!
        # Example: only allow owner or admin
        # owner = @user || @user_address&.user
        # return if current_user&.admin? || (owner && current_user&.id == owner.id)
        true
      end
    end
  end
end
