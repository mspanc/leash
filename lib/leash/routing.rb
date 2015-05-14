module ActionDispatch::Routing
  class Mapper
    def leash
      scope :oauth do
        get  "authorize", to: "leash/server/authorize#authorize", as: "leash_server_authorize"
        post "token",     to: "leash/server/token#token",         as: "leash_server_token"
      end
    end
  end
end

