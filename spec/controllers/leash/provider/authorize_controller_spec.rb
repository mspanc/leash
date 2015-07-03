require 'spec_helper'

RSpec.describe Leash::Provider::AuthorizeController, :type => :controller do
  before do
    @OLD_ENV = ENV
    ENV["APP_TEST_OAUTH2_CLIENT_ID"] = "123456"
    ENV["APP_TEST_OAUTH2_SECRET"] = "qwerty"
    ENV["APP_TEST_OAUTH2_REDIRECT_URL"] = "http://example.com"  # TODO test multiple allowed redirect urls
    
    allow(Leash::Provider).to receive(:user_roles).and_return([ valid_user_role ])
  end

  after do
    (ENV.keys - @OLD_ENV.keys).each{ |key| ENV.delete(key) }
  end

  let(:app_name)             { "test" }
  let(:valid_user_role)      { "Admin" }
  let(:valid_client_id)      { ENV["APP_TEST_OAUTH2_CLIENT_ID"] }
  let(:valid_redirect_uri)   { ENV["APP_TEST_OAUTH2_REDIRECT_URL"] }
  let(:unknown_user_role)    { "Ufo" }
  let(:unknown_client_id)    { "098765" }
  let(:unknown_redirect_uri) { "http://whatever.com" }
  let(:authentication_route) { new_admin_session_path }


  describe "GET authorize" do
    context "for authorization code flow" do
      let(:response_type) { "code" }
      
      pending "without all necessary params"

      context "with all necessary params" do
        let(:params) { { user_role: user_role, response_type: response_type, client_id: client_id, redirect_uri: redirect_uri } }
      
        context "with unknown client_id" do
          let(:client_id) { unknown_client_id }

          context "with valid redirect_uri" do
            let(:redirect_uri) { valid_redirect_uri }

            context "with valid user role" do
              let(:user_role) { valid_user_role }

              before do
                get :authorize, params
              end

              it "should return 422 status" do
                expect(response.status).to eq 422
              end

              it "should return 'unknown_client_id' in the response" do
                expect(response.body).to eq "unknown_client_id"
              end
            end
          end
        end

        context "with valid client_id" do
          let(:client_id) { valid_client_id }
  
          context "with unknown redirect_uri" do
            let(:redirect_uri) { unknown_redirect_uri }

            context "with valid user role" do
              let(:user_role) { valid_user_role }

              before do
                get :authorize, params
              end

              it "should return 422 status" do
                expect(response.status).to eq 422
              end

              it "should return 'unknown_redirect_uri' in the response" do
                expect(response.body).to eq "unknown_redirect_uri"
              end
            end
          end

          context "with valid redirect_uri" do
            let(:redirect_uri) { valid_redirect_uri }

            context "but with unknown user_role" do
              let(:user_role) { unknown_user_role }

              before do
                get :authorize, params
              end

              it "should return 422 status" do
                expect(response.status).to eq 422
              end

              it "should return 'unknown_user_role' in the response" do
                expect(response.body).to eq "unknown_user_role"
              end
            end  

            context "with valid user role" do
              let(:user_role) { valid_user_role }


              before do
                get :authorize, params
              end


              context "if not authenticated" do
                it "should redirect to devise sign in screen for this user role" do
                  expect(response).to redirect_to(authentication_route)
                end
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


    context "for implicit flow" do
      let(:response_type) { "token" }

      pending "without all necessary params"

      context "with all necessary params" do
        let(:params) { { user_role: user_role, response_type: response_type, client_id: client_id, redirect_uri: redirect_uri } }
      
        context "with unknown client_id" do
          let(:client_id) { unknown_client_id }

          context "with valid redirect_uri" do
            let(:redirect_uri) { valid_redirect_uri }

            context "with valid user role" do
              let(:user_role) { valid_user_role }

              before do
                get :authorize, params
              end

              it "should return 422 status" do
                expect(response.status).to eq 422
              end

              it "should return 'unknown_client_id' in the response" do
                expect(response.body).to eq "unknown_client_id"
              end
            end
          end
        end

        context "with valid client_id" do
          let(:client_id) { valid_client_id }
  
          context "with unknown redirect_uri" do
            let(:redirect_uri) { unknown_redirect_uri }

            context "with valid user role" do
              let(:user_role) { valid_user_role }

              before do
                get :authorize, params
              end

              it "should redirect to the first redirect_uri specified in the app with appended '#error=unknown_redirect_uri'" do
                expect(response).to redirect_to("#{valid_redirect_uri}#error=unknown_redirect_uri")
              end
            end
          end

          context "with valid redirect_uri" do
            let(:redirect_uri) { valid_redirect_uri }

            context "but with unknown user_role" do
              let(:user_role) { unknown_user_role }

              before do
                get :authorize, params
              end

              it "should redirect to the first redirect_uri specified in the app with appended '#error=unknown_user_role'" do
                expect(response).to redirect_to("#{valid_redirect_uri}#error=unknown_user_role")
              end
            end  

            context "with valid user role" do
              let(:user_role) { valid_user_role }


              context "if not authenticated" do
                before do
                  get :authorize, params
                end
  
                it "should redirect to devise sign in screen for this user role" do
                  expect(response).to redirect_to(authentication_route)
                end
              end


              context "if authenticated" do
                let(:admin) { create(:admin) }

                context "and there is already an access token for this app_name/owner combination" do
                  context "and Leash::Provider.reuse_access_tokens is set to true" do
                    before do
                      expect(Leash::Provider).to receive(:reuse_access_tokens).and_return(true)

                      @existing_access_token = Leash::Provider::AccessToken.assign! app_name, admin

                      sign_in admin
                      get :authorize, params
                    end

                    it "should redirect to the redirect_uri specified in the params with appended '#access_token=(already present access token)'" do
                      expect(response).to redirect_to("#{valid_redirect_uri}#access_token=#{URI.encode(@existing_access_token)}")
                    end
                  end
                  
                  context "and Leash::Provider.reuse_access_tokens is set to false" do
                    before do
                      expect(Leash::Provider).to receive(:reuse_access_tokens).and_return(false)

                      @existing_access_token = Leash::Provider::AccessToken.assign! app_name, admin

                      sign_in admin
                      get :authorize, params
                    end

                    it "should redirect to the redirect_uri specified in the params with appended '#access_token=(newly generated access token)'" do
                      expect(response).not_to redirect_to("#{valid_redirect_uri}#access_token=#{URI.encode(@existing_access_token)}")
                      expect(response).to redirect_to("#{valid_redirect_uri}#access_token=#{Leash::Provider::AccessToken.find_by_app_name_and_owner(app_name, admin).access_token}")
                    end
                  end
                end
                
                context "and there is are no access token for this app_name/owner combination" do
                  before do
                    sign_in admin
                    get :authorize, params
                  end

                  it "should redirect to the redirect_uri specified in the app with appended '#access_token=(newly generated access token)'" do
                    expect(response).to redirect_to("#{valid_redirect_uri}#access_token=#{URI.encode(Leash::Provider::AccessToken.find_by_app_name_and_owner(app_name, admin).access_token)}")
                  end
                end
              end
            end          
          end
        end
      end
    end
  end
end
