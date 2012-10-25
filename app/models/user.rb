class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :reverse_relationships, foreign_key: 'followed_id', 
                                    class_name: 'Relationship', dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :followers, through: :reverse_relationships
  has_secure_password
  
  before_save {self.email.downcase!}
  before_save :create_remember_token

  def feed
    # Micropost.where("user_id = ?", id)
    Micropost.from_users_followed_by(self)
  end

  def following? user
    relationships.find_by_followed_id(user.id)
  end

  def follow! user
    relationships.create!(followed_id: user.id)
  end

  def unfollow! user
    relationships.find_by_followed_id(user.id).destroy if following? user
  end

  def create_remember_token
  	self.remember_token = SecureRandom.urlsafe_base64
  end

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true, length: {maximum: 50}
  validates :password, length: {minimum: 6}
  validates :password_confirmation, presence: true
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, 
  									uniqueness: {case_sensitive: false}
end
