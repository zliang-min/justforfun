# encoding: utf-8
# @author 梁智敏

# 公司员工。一般用作后台登录。
class Employee < UserBase
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :ldap_authenticatable,
         :trackable, :validatable,
         :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessor   :password
  attr_accessible :email
end
