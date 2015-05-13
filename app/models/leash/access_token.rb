class Leash::AccessToken < Ohm::Model
  MAX_ASSIGN_TRIES = 20

  attribute :app_name
  attribute :access_token
  attribute :owner
  attribute :created_at
  attribute :accessed_at

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
        self.create app_name: app_name, owner: owner, access_token: access_token, created_at: timestamp, accessed_at: timestamp
        break
      
      rescue Ohm::UniqueIndexViolation => e
        tries += 1

        fail if tries > MAX_ASSIGN_TRIES
      end
    end

    access_token
  end


  def self.valid?(access_token)
    self.find(access_token: access_token).size != 0
  end


  def self.find_by_access_token(access_token)
    self.find(access_token: access_token).first
  end
end