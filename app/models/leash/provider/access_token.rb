class Leash::Provider::AccessToken < Ohm::Model
  MAX_ASSIGN_TRIES = 20

  attribute :app_name
  attribute :access_token
  attribute :owner
  attribute :created_at
  attribute :accessed_at

  index :app_name
  index :owner
  index :access_token
  index :accessed_at
  unique :access_token


  def self.assign!(app_name, owner)
    tries = 0
    access_token = nil

    loop do
      begin
        access_token = SecureRandom.hex(24)
        timestamp = Time.now.to_i
        self.create app_name: app_name, owner: owner_key(owner), access_token: access_token, created_at: timestamp, accessed_at: timestamp
        break
      
      rescue Ohm::UniqueIndexViolation => e
        tries += 1

        fail if tries > MAX_ASSIGN_TRIES
      end
    end

    access_token
  end


  def self.assign_from_auth_code!(auth_code)
    access_token = assign! auth_code.app_name, auth_code.owner
    auth_code.delete
    access_token
  end


  def self.valid?(access_token)
    self.find(access_token: access_token).size != 0
  end


  def self.find_by_access_token(access_token)
    self.find(access_token: access_token).sort_by(:created_at, order: "DESC").first
  end


  def self.find_by_app_name_and_owner(app_name, owner)
    self.find(app_name: app_name, owner: owner_key(owner)).sort_by(:created_at, order: "DESC").first
  end


  def self.owner_key(owner)
    if owner.is_a? ActiveRecord::Base
      "#{owner.class.name}##{owner.id}"
    else
      owner
    end
  end


  def owner_instance
    owner_klass, owner_id = owner.split("#", 2)

    owner_klass.classify.constantize.find(owner_id)
  end


  def touch!
    update accessed_at: Time.now.to_i
  end
end