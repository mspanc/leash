class Leash::Provider::TokenController < Leash::ProviderController
  GRANT_TYPES = [ "authorization_code" ].freeze

  before_action :set_no_cache_headers
  before_action :determine_grant_type!

  def token
    case @grant_type
    when "authorization_code"
      params.require("code")

      # Rails.logger.info "[Leash::Provider] Code<->Token exchange: #{params.inspect}"
      callback_with_error "invalid_grant", "Given auth code does not exist" and return unless Leash::Provider::AuthCode.present?(params[:code])

      auth_code = Leash::Provider::AuthCode.find_by_auth_code(params[:code])
      callback_with_error "invalid_grant", "Given redirect URI does not match one specified in the authorization request" and return unless auth_code.redirect_uri == params[:redirect_uri]
      # TODO if client_id and client_secret is present, try to match it with ENV vars

      access_token = Leash::Provider::AccessToken.assign_from_auth_code! Leash::Provider::AuthCode.find_by_auth_code(params[:code])
      Rails.logger.info "[Leash::Provider] Code<->Token exchange ok: grant_type=#{@grant_type} auth_code=#{params[:code]} access_token=#{access_token} request_ip=#{request.remote_ip} request_user_agent=#{request.user_agent}"
      render json: { access_token: access_token, token_type: "bearer" }

    else
      fail # Should not be reached
    end
  end


  protected


  def callback_with_error(error_code, message)
    Rails.logger.warn "[Leash::Provider] Token error: #{error_code} (#{message})"

    case @grant_type
    when "authorization_code"
      render json: { error: error_code, error_description: message }, status: :unprocessable_entity
    end
  end


  def determine_grant_type!
    params.require("grant_type")

    if GRANT_TYPES.include? params[:grant_type]
      @grant_type = params[:grant_type]
    else
      callback_with_error "unsupported_grant_type", "Unknown grant type of '#{params[:grant_type]}'"
    end
  end
end
