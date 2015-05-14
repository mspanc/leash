module ActionDispatch::Routing
  class Mapper
    def leash_provider
      scope :oauth do
        get  "authorize", to: "leash/provider/authorize#authorize", as: "leash_provider_authorize"
        post "token",     to: "leash/provider/token#token",         as: "leash_provider_token"
      end
    end
  end
end

