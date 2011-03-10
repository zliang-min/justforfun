# encoding: utf-8
# @author 梁智敏

# 公司员工。一般用作后台登录。
class Employee < AbstractUser
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :ldap_authenticatable,
         :trackable,
         :validatable,
         :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email
  # 密码不需要保存在数据库
  attr_accessor   :password
end
