class Leash::Server::AuthorizeController < Leash::ServerController
  ROLES            = [ "editor" ].freeze
  RESPONSE_TYPES   = [ "token" ].freeze
  CLIENT_ID_REGEXP = /\AAPP\_([A-Z0-9\_]+)\_CLIENT\_ID\z/.freeze
  MAX_TRIES        = 20

  before_filter :determine_client_id!
  before_filter :determine_role!
  before_filter :authenticate_user_by_role!


  def authorize
    params.require("response_type")
    params.require("redirect_uri")



    if RESPONSE_TYPES.include? params[:response_type]
      response_type = params[:response_type]
    else
      Rails.logger.warn "[OAuth] Authorize error: Unknown response type of '#{params[:response_type]}'"
      render text: "Unknown response type", status: :unprocessable_entity
    end


    token = nil
    tries = 0
    user_id = send("current_#{@role}").id

    loop do
      begin
        token = SecureRandom.hex(24)
        timestamp = Time.now.to_i
        Leash::AccessToken.create app_name: @app_name, owner: "#{@role}##{user_id}", token: token, created_at: timestamp, accessed_at: timestamp
        break
      
      rescue Ohm::UniqueIndexViolation => e
        tries += 1

        fail if tries > MAX_TRIES
      end
    end

    Rails.logger.info "[OAuth] Authorize ok: app_name=#{@app_name} user_role=#{@role} user_id=#{user_id} request_ip=#{request.remote_ip} request_user_agent=#{request.user_agent}"
    redirect_to @redirect_url + "#access_token=#{URI.encode(token)}"
  end



  private

  def determine_client_id!
    params.require("client_id")

    # FIXME can be suboptimal but for now let it be
    # Env vars simplicity FTW!
    ENV.find{ |k,v| k =~ CLIENT_ID_REGEXP and v == params[:client_id] }
    
    if $1
      env_name = $1.dup
      @app_name = env_name.gsub("_", "-").downcase
      @redirect_url = ENV["OAUTH_#{env_name}_REDIRECT_URL"]

      if @redirect_url
        if @redirect_url != params[:redirect_uri]
          Rails.logger.warn "[OAuth] Authorize error: Redirect URL mismatch (should be '#{@redirect_url}', given '#{params[:redirect_uri]}'"
          redirect_to @redirect_url + "#error=invalid_redirect_uri"
        end      
      else
        Rails.logger.warn "[OAuth] Authorize error: Unable to find redirect URL associated with app '#{app_name}'"
        render text: "Internal error: Unable to find redirect URL associated with app '#{app_name}'", status: :internal_server_error
      end

    else
      Rails.logger.warn "[OAuth] Authorize error: Unknown client ID '#{params[:client_id]}'"
      render text: "Unknown client ID", status: :unprocessable_entity
    end
  end


  def determine_role!
    params.require("role")

    if ROLES.include? params[:role]
      @role = params[:role]
    else
      Rails.logger.warn "[OAuth] Authorize error: Unknown role of '#{params[:role]}'"

      redirect_to @redirect_url + "#error=invalid_role"
    end
  end


  def authenticate_user_by_role!
    send "authenticate_#{@role}!"
  end
end