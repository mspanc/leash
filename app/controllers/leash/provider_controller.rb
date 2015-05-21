class Leash::ProviderController < LeashController
  include Devise::Controllers::Helpers
  
  CLIENT_ID_REGEXP = /\AAPP\_([A-Z0-9\_]+)\_OAUTH2\_CLIENT\_ID\z/.freeze

  protected

  def current_owner
    send("current_#{@user_role_underscored}")
  end


  def determine_client_id!
    params.require("client_id")

    # FIXME can be suboptimal but for now let it be
    # Env vars simplicity FTW!
    ENV.find{ |k,v| k =~ CLIENT_ID_REGEXP and v == params[:client_id] }
    if $1
      @client_id = params[:client_id]
      @env_name = $1.dup
      @app_name = @env_name.gsub("_", "-").downcase

    else
      callback_with_error "unknown_client_id", "Unknown client ID '#{params[:client_id]}'"
    end
  end


  def determine_redirect_url!
    params.require("redirect_uri")

    @redirect_url = ENV["APP_#{@env_name}_OAUTH2_REDIRECT_URL"]
    if @redirect_url and not @redirect_url.blank?
      @redirect_urls = @redirect_url.split(" ")
      unless @redirect_urls.include? params[:redirect_uri]
        callback_with_error "invalid_redirect_uri", "Redirect URL mismatch (should be '#{@redirect_url}', given '#{params[:redirect_uri]}'"
      end

    else
      callback_with_error "unknown_redirect_uri", "Unable to find redirect URL associated with app '#{@app_name}'"
    end
  end


  def determine_client_secret!
    params.require("client_secret")

    @client_secret = ENV["APP_#{@env_name}_OAUTH2_SECRET"]
    if @client_secret
      unless @client_secret == params[:client_secret]
        callback_with_error "invalid_secret", "Secret mismatch"
      end
    else
      callback_with_error "unknown_secret", "Unable to find secret associated with app '#{@app_name}'"
    end
  end


  def callback_with_error(error_code, message)
    fail "Please override this method"
  end
end
