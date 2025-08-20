class ApplicationController < ActionController::API

  include ActionController::MimeResponds
  include Devise::Controllers::Helpers

  respond_to :json
  before_action :authorize_request
  before_action :debug_auth_ids!, if: -> { Rails.env.development? || Rails.env.test? }

  private
  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    if header.present?
      begin
        payload, _ = JWT.decode(header, nil, false) 
        @current_user = User.find(payload['sub'])
      rescue => e
        render json: { error: 'Incorrect token' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing Authorized Token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
  
  def debug_auth_ids!
    jwt = request.headers['Authorization']&.split&.last
    payload =
      begin
        jwt ? Warden::JWTAuth::TokenDecoder.new.call(jwt) : nil
      rescue StandardError
        nil
      end

    Rails.logger.info(
      "[AUTH] current_user.id=#{current_user&.id} email=#{current_user&.email} | "\
      "JWT.sub=#{payload && payload['sub']} | path.user_id=#{params[:user_id].inspect}"
    )
  end
end
