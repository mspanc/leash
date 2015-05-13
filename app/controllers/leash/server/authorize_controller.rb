class Leash::Server::AuthorizeController < Leash::ServerController
  RESPONSE_TYPES   = [ "token", "code" ].freeze

  before_action :determine_response_type!
  before_action :determine_user_role!
  before_action :authenticate_user_by_role!


  def authorize
    owner = "#{@role_class.name}##{send("current_#{@role_name_underscored}").id}"

    case @response_type
    when "token"
      access_token = Leash::AccessToken.assign! @app_name, owner
  
      Rails.logger.info "[Leash::Server] Authorize ok: response_type=#{@response_type} app_name=#{@app_name} owner=#{owner} access_token=#{access_token} request_ip=#{request.remote_ip} request_user_agent=#{request.user_agent}"
      redirect_to @redirect_url + "#access_token=#{URI.encode(access_token)}"

    when "code"
      auth_code = Leash::AuthCode.assign! @app_name, owner
  
      Rails.logger.info "[Leash::Server] Authorize ok: response_type=#{@response_type} owner=#{owner} auth_code=#{auth_code} request_ip=#{request.remote_ip} request_user_agent=#{request.user_agent}"
      redirect_to @redirect_url + "?code=#{URI.encode(auth_code)}"
    end
  end


  protected


  def callback_with_error(error_code, message)
    Rails.logger.warn "[Leash::Server] Authorize error: #{error_code} (#{message})"
    if @redirect_url
      redirect_to @redirect_url + "#error=#{error_code}"
    else
      render text: error_code, status: :unprocessable_entity
    end
  end


  def determine_user_role!
    params.require("user_role")

    fail "Leash.user_roles must be an array" unless Leash.user_roles.is_a? Array

    if Leash.user_roles.include? params[:user_role].to_s
      @role_class = params[:user_role].constantize
      @role_name_underscored = params[:user_role].underscore.gsub("/", "_")

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
    send "authenticate_#{@role_name_underscored}!"
  end
end