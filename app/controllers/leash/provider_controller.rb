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
      begin
        redirect_uri_parsed = URI.parse(params[:redirect_uri])
      rescue URI::InvalidURIError => e
        callback_with_error "invalid_redirect_uri", "Redirect URL has invalid syntax, given '#{params[:redirect_uri]}'"
        return
      end

      unless redirect_uri_parsed.fragment.nil?
        callback_with_error "invalid_redirect_uri", "Redirect URL contains fragment, given '#{params[:redirect_uri]}'"
        return
      end

      @redirect_urls = @redirect_url.split(" ")
    
      @redirect_urls.each do |known_redirect_url|
        if known_redirect_url.end_with? "*"
          if params[:redirect_uri].start_with? known_redirect_url[0..-2] 
            # Found!
            return
          end

        else 
          if known_redirect_url == params[:redirect_uri]
            # Found!
            return
          end
        end
      end    

      callback_with_error "unknown_redirect_uri", "Redirect URL mismatch (should be one of '#{@redirect_url}', given '#{params[:redirect_uri]}'"
      return
      
    else
      callback_with_error "configuration_error", "Unable to find redirect URLs associated with app '#{@app_name}'"
      return
    end
  end


  def determine_client_secret!
    params.require("client_secret")

    @client_secret = ENV["APP_#{@env_name}_OAUTH2_SECRET"]
    if @client_secret
      unless @client_secret == params[:client_secret]
        callback_with_error "unknown_secret", "Secret mismatch"
      end
    else
      callback_with_error "configuration_error", "Unable to find secret associated with app '#{@app_name}'"
    end
  end


  def callback_with_error(error_code, message)
    fail "Please override this method"
  end
end
