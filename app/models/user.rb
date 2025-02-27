class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  
  attr_accessor :remember_token, :activation_token, :reset_token
  
  before_create :create_activation_digest # Rails looks for a method called create_activation_digest
  before_save :downcase_email
  
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
    # instead of the result of update_attribute.
    remember_digest
  end
  
  # Returns a session token to prevent session hijacking.
  # We reuse the remember digest for convenience.
  def session_token
    remember_digest || remember
  end
  
  # Returns true if the given token matches the digest, otherwise false.
  # attribute should be something like :remember, or :activation
  # better name valid_token?
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def validate_reset(id)
    self.activated? && self.authenticated?(:reset, id)
  end
  
  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    reset_digest = User.digest(reset_token)
    update_columns(reset_digest: reset_digest, reset_send_at: Time.zone.now)
  end
    
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_send_at < 2.hours.ago
  end

  # Returns a user's status feed   
  def feed
    # Micropost.where("user_id IN (?) OR user_id = ? ", self.following.map(&:id), self.id )
    # Micropost.where("user_id IN (?) OR user_id = ? ", self.following_ids, self.id )
     following_ids_subselect = "SELECT followed_id FROM relationships 
                               WHERE follower_id = :user_id"
     Micropost.where("user_id IN (#{following_ids_subselect})
                     OR user_id = :user_id", user_id: self.id)
    # always escape variables injected into SQL statements!
    
    # part_of_feed = "relationships.follower_id = :id or microposts.user_id = :id"
    # Micropost.joins(user: :followers).where(part_of_feed, { id: id })
  end
  
  # Follows a user.
  def follow(other_user)
    # active_relationships.create(followed_id: other_user.id)
    following << other_user
  end
    
  # Unfollows a user.
  def unfollow(other_user)
    # active_relationships.find_by(followed_id: other_user.id).destroy
    following.delete(other_user)
  end
  
  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end
  
  private   
    
    # Converts email to all lower-case.
    def downcase_email
      email.downcase!
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
