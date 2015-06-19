module ActionDispatch::Routing
  class Mapper
    def leash_provider
      scope :oauth2 do
        get  "authorize/:user_role", to: "leash/provider/authorize#authorize", as: "leash_provider_authorize"
        post "token",                to: "leash/provider/token#token",         as: "leash_provider_token"
        get  "user_info",            to: "leash/provider/user_info#info",      as: "leash_provider_user_info"
      end
    end
  end
end
