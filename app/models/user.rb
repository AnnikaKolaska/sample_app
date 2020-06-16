class User < ApplicationRecord
  
  attr_accessor :remember_token
  
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  # VALID_EMAIL_REGEX = /\A([\w+\-.]+)@[a-z\d\-]+\.{0,1}[a-z\d\-]+\.[a-z]+\z/i   works too, but not right
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password # includes a separate presence validation that specifically catches nil passwords.
  # allow_nil: true, to allow updating profile without having to put in password. 
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true 
  
  # Returns the hash digest of any given string. (This is a class-method)
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Returns a random token (to remember a user)
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    hashed_token = User.digest(remember_token)
    # this method bypasses the validations, which is necessary in this case because we don’t have access to the user’s password.
    update_attribute(:remember_digest, hashed_token )
    # now this method returns the hashed remember token
    # instead of the result of update_attribute (how the f is this not breaking anything?)
    remember_digest
  end
  
  # Returns a session token to prevent session hijacking.
  # We reuse the remember digest for convenience.
  def session_token
    remember_digest || remember
  end
  
  # Returns true if the given token matches the digest, otherwise false.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
