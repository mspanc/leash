class Leash::Provider::AuthorizeController < Leash::ProviderController
  RESPONSE_TYPES   = [ "token", "code" ].freeze

  before_action :determine_response_type!
  before_action :determine_client_id!
  before_action :determine_redirect_url!
  before_action :determine_user_role!
  before_action :authenticate_user_by_role!


  def authorize
    case @response_type
    when "token"
      if Leash::Provider.reuse_access_tokens == true
        access_token_obj = Leash::Provider::AccessToken.find_by_app_name_and_owner @app_name, current_owner

        if access_token_obj
          access_token = access_token_obj.access_token
        else
          access_token = Leash::Provider::AccessToken.assign! @app_name, current_owner
        end

      else
        access_token = Leash::Provider::AccessToken.assign! @app_name, current_owner
      end

      Rails.logger.info "[Leash::Provider] Authorize ok: response_type=#{@response_type} app_name=#{@app_name} current_owner=#{current_owner.class.name}##{current_owner.id} access_token=#{access_token} request_ip=#{request.remote_ip} request_user_agent=#{request.user_agent}"
      redirect_to params[:redirect_uri] + "#access_token=#{URI.encode(access_token, "=&")}"

    when "code"
      auth_code = Leash::Provider::AuthCode.assign! @app_name, current_owner
  
      Rails.logger.info "[Leash::Provider] Authorize ok: response_type=#{@response_type} current_owner=#{current_owner.class.name}##{current_owner.id} auth_code=#{auth_code} request_ip=#{request.remote_ip} request_user_agent=#{request.user_agent}"
      redirect_to params[:redirect_uri] + "?code=#{URI.encode(auth_code, "=&")}"

    else
      fail "Should not be reached"
    end
  end


  protected


  def callback_with_error(error_code, message)
    Rails.logger.warn "[Leash::Provider] Authorize error: #{error_code} (#{message})"

    case @response_type
    when "token"
      if @redirect_url
        redirect_to @redirect_urls.first + "#error=#{error_code}"
      else
        render text: error_code, status: :unprocessable_entity
      end

    when "code"
      render text: error_code, status: :unprocessable_entity
    
    else
      fail "Should not be reached"
    end
  end


  def determine_user_role!
    params.require("user_role")

    if Leash::Provider.user_roles.include? params[:user_role].to_s
      @user_role = params[:user_role]
      @user_role_underscored = params[:user_role].underscore.gsub("/", "_")

    else
      callback_with_error "invalid_user_role", "Authorize error: Unknown role of '#{params[:user_role]}'"
    end
  end


  def determine_response_type!
    params.require("response_type")

    if RESPONSE_TYPES.include? params[:response_type]
      @response_type = params[:response_type]
    else
      callback_with_error "unknown_response_type", "Unknown response type of '#{params[:response_type]}'"
    end
  end


  def authenticate_user_by_role!
    send "authenticate_#{@user_role_underscored}!"
  end
end