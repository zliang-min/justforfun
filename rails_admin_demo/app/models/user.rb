# encoding: utf-8
# @author 梁智敏

# 网站用户。即非管理后台的帐户。
class User < AbstractUser
  attr_accessible :name

  validates :name, presence: true, length: {maximum: 100}
end
