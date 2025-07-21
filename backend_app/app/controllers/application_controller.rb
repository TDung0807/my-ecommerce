class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  # Disable Devise session usage
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    request.session_options[:skip] = true
  end
end
