class ApplicationController < ActionController::API

  include ActionController::MimeResponds
  include Devise::Controllers::Helpers

  respond_to :json
  before_action :authorize_request

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
end
