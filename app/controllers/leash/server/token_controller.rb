class Leash::Server::TokenController < Leash::ServerController
  before_action :determine_role!
  before_action :authenticate_user_by_role!


  def token
    # TODO
  end


end