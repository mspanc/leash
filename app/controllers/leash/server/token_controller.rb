class Leash::Server::TokenController < Leash::ServerController
  GRANT_TYPES = [ "authorization_code" ].freeze

  before_action :determine_grant_type!
  before_action :determine_client_id!
  before_action :determine_client_secret!


  def token
    case @grant_type
    when "authorization_code"
      params.require("code")

      if Leash::AuthCode.valid?(params[:code])
        access_token = Leash::AccessToken.assign_from_auth_code! Leash::AuthCode.find_by_auth_code(params[:code])
        
        render json: { access_token: access_token }
      end

    else
      fail "Should not be reached"
    end
  end


  protected


  def callback_with_error(error_code, message)
    Rails.logger.warn "[Leash::Server] Token error: #{error_code} (#{message})"
    
    case @grant_type
    when "authorization_code"
      render json: { error: error_code }, status: :unprocessable_entity
    end
  end


  def determine_grant_type!
    params.require("grant_type")

    if GRANT_TYPES.include? params[:grant_type]
      @grant_type = params[:grant_type]
    else
      callback_with_error "unknown_grant_type", "Unknown grant type of '#{params[:grant_type]}'"
    end
  end
end