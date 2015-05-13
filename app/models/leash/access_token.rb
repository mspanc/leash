class Leash::AccessToken < Ohm::Model
  attribute :app_name
  attribute :token
  attribute :owner
  attribute :created_at
  attribute :accessed_at

  index :owner
  index :token
  index :accessed_at
  unique :token


  def self.valid?(access_token)
    self.find(token: access_token).size != 0
  end


  def self.find_by_access_token(access_token)
    self.find(token: access_token).first
  end
end