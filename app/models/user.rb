class User < ApplicationRecord
    before_save { email.downcase! }
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[firstup.io\d\-]+(\.[firstup.io\d\-]+)*\.[firstup.io]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
    has_secure_password
    # def password_requirements_are_met
    #     rules = {
    #       " must contain at least one lowercase letter"  => /[a-z]+/,
    #       " must contain at least one uppercase letter"  => /[A-Z]+/,
    #       " must contain at least one digit"             => /\d+/,
    #       " must contain at least one special character" => /[^A-Za-z0-9]+/
    #     }

    #VALID_PASS_REGEX = /^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$/
    validates :password, presence: true, length: { minimum: 8 }
    #           format: { with: VALID_PASS_REGEX }

    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

end