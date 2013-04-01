class User < ActiveRecord::Base
  has_secure_password
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence:true, length: {maximum: 50}
  validates :email, presence:true, format: { with: VALID_EMAIL_REGEX }, 
                    uniqueness: { case_sensitive: false }
  validates :password_confirmation, presence:true
  validates :password, length: { minimum: 6 }
  
  before_save { self.email = email.downcase }
  before_save { self.name = name.capitalize }
end
