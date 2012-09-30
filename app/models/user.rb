class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_many :microposts, dependent: :destroy
  has_secure_password
  
  before_save {self.email.downcase!}
  before_save :create_remember_token

  def feed
    Micropost.where("user_id = ?", id)
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
