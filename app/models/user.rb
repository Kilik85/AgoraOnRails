class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :facebook_id
  
  has_many :votes
  has_many :voted_proposals, :through => :votes, :source => :proposal
  belongs_to :spokesman, :class_name => "User", :counter_cache => :represented_users_count
  has_many :represented_users, :class_name => "User", :foreign_key => :spokesman_id
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def has_voted_for?(proposal)
    voted_proposals.include?(proposal)
  end
    
  def delegated_vote_for(proposal)
    return nil if has_voted_for?(proposal) or spokesman.nil? 
    spokesman.has_voted_for?(proposal) ? spokesman.votes.find_by_proposal_id(proposal) : nil
  end
  
  # def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
  #     data = ActiveSupport::JSON.decode(access_token.get('/me'))
  #     if user = User.find_by_email(data["email"])
  #       user
  #     else
  #       User.create!(:name => data["name"], :email => data["email"], :facebook_id => data["id"], :facebook_profile => data["link"])
  #     end
  #   end
     
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token["extra"]["user_hash"]
    
    if user = User.find_by_email(data["email"])
      user
    else # Create an user with a stub password. 
      user = User.create!(:email => data["email"], 
                          :first_name =>  data['first_name'],
                          :last_name =>  data['last_name'],
                          :facebook_id => data['id'], 
                          :password => Devise.friendly_token[0,20])
    end 
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"]
        user.email = data["email"]
      end
    end
  end

end