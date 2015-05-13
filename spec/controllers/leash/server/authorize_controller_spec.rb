require 'spec_helper'

RSpec.describe Leash::Server::AuthorizeController, :type => :controller do
  before do
    @OLD_ENV = ENV
    ENV["APP_TEST_CLIENT_ID"] = "123456"
    ENV["APP_TEST_REDIRECT_URL"] = "http://example.com"
  end

  after do
    (ENV.keys - @OLD_ENV.keys).each{ |key| ENV.delete(key) }
  end

  let(:valid_role)           { "editor" }
  let(:valid_client_id)      { ENV["APP_TEST_CLIENT_ID"] }
  let(:valid_redirect_uri)   { ENV["APP_TEST_REDIRECT_URL"] }
  let(:invalid_role)         { "ufo" }
  let(:invalid_client_id)    { "098765" }
  let(:invalid_redirect_uri) { "http://whatever.com" }


  describe "GET authorize" do
    context "for token flow" do
      let(:response_type) { "token" }

      pending "without all necessary params"

      context "with all necessary params" do
        let(:params) { { role: role, response_type: response_type, client_id: client_id, redirect_uri: redirect_uri } }
      
        context "with invalid client_id" do
          let(:client_id) { invalid_client_id }

          context "with valid redirect_uri" do
            let(:redirect_uri) { valid_redirect_uri }

            context "with valid role" do
              let(:role) { valid_role }

              before do
                get :authorize, params
              end

              it "should return 422 status" do
                expect(response.status).to eq 422
              end

              it "should return 'Unknown client ID' in the response" do
                expect(response.body).to eq "Unknown client ID"
              end
            end
          end
        end

        context "with valid client_id" do
          let(:client_id) { valid_client_id }
  
          context "with invalid redirect_uri" do
            let(:redirect_uri) { invalid_redirect_uri }

            context "with valid role" do
              let(:role) { valid_role }

              before do
                get :authorize, params
              end

              it "should redirect to the redirect_uri specified in the app with appended '#error=invalid_redirect_uri'" do
                expect(response).to redirect_to("#{valid_redirect_uri}#error=invalid_redirect_uri")
              end
            end
          end

          context "with valid redirect_uri" do
            let(:redirect_uri) { valid_redirect_uri }

            context "but with unknown role" do
              let(:role) { invalid_role }

              before do
                get :authorize, params
              end

              it "should redirect to the redirect_uri specified in the app with appended '#error=invalid_role'" do
                expect(response).to redirect_to("#{valid_redirect_uri}#error=invalid_role")
              end
            end  

            context "with valid role" do
              let(:role) { valid_role }

              before do
                get :authorize, params
              end


              context "if not authenticated" do
                pending "it should redirect to devise login screen for this role"
              end


              context "if authenticated" do
                context "and there is already an access token for this app_name/owner combination" do
                  pending "should redirect to the redirect_uri specified in the app with appended '#access_token=(already present access token)'"
                end
                
                context "and there is are no access token for this app_name/owner combination" do
                  pending "should redirect to the redirect_uri specified in the app with appended '#access_token=(newly generated access token)'"
                end
              end
            end          
          end
        end
      end
    end
  end
end
