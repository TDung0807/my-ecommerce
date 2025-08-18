# load via rails_helper (Dir[...] require)
module AuthHelper
  def auth_headers_for(user = nil)
    user ||= FactoryBot.create(:user)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    {
      "Authorization" => "Bearer #{token}",
      "CONTENT_TYPE"  => "application/json",
      "ACCEPT"        => "application/json"
    }
  end
end

RSpec.configure { |c| c.include AuthHelper }
