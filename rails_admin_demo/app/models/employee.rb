class Employee < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :ldap_authenticatable,
         :trackable, :validatable,
         :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email
end
