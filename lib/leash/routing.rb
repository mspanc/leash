module ActionDispatch::Routing
  class Mapper
    def leash_server
      scope :oauth do
        get "authorize", to: "leash/server/authorize#authorize"
      end
    end
  end
end

