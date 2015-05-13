class Leash::ServerController < LeashController
  CLIENT_ID_REGEXP = /\AAPP\_([A-Z0-9\_]+)\_CLIENT\_ID\z/.freeze

  before_action :determine_client_id!

  protected

  def determine_client_id!
    params.require("client_id")
    params.require("redirect_uri")

    # FIXME can be suboptimal but for now let it be
    # Env vars simplicity FTW!
    ENV.find{ |k,v| k =~ CLIENT_ID_REGEXP and v == params[:client_id] }
    
    if $1
      env_name = $1.dup
      @app_name = env_name.gsub("_", "-").downcase
      @redirect_url = ENV["OAUTH_#{env_name}_REDIRECT_URL"]

      if @redirect_url
        if @redirect_url != params[:redirect_uri]
          callback_with_error "invalid_redirect_uri", "Redirect URL mismatch (should be '#{@redirect_url}', given '#{params[:redirect_uri]}'"
        end
      
      else
        callback_with_error "unknown_redirect_uri", "Unable to find redirect URL associated with app '#{@app_name}'"
      end

    else
      callback_with_error "unknown_client_id", "Unknown client ID '#{params[:client_id]}'"
    end
  end
 

  def callback_with_error(error_code, message)
    # Please override this method
  end
end