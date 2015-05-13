class Leash::Server::AuthorizeController < Leash::ServerController
  RESPONSE_TYPES   = [ "token", "code" ].freeze

  before_action :determine_response_type!
  before_action :determine_role!
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
      redirect_to @redirect_url + "#error=invalid_role"
    else
      render text: error_code, status: :unprocessable_entity
    end
  end


  def determine_role!
    params.require("role")

    fail "Leash.user_classes must be an array" unless Leash.user_classes.is_a? Array
    if Leash.user_classes.include? params[:role].to_s
      @role_class = params[:role].constantize
      @role_name_underscored = params[:role].underscore.gsub("/", "_")

    else
      callback_with_error "invalid_role", "Authorize error: Unknown role of '#{params[:role]}'"
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