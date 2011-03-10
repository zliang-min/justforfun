# encoding: utf-8
# @uathor 梁智敏

# 用户的基类。提供一些公共的接口、i18n等等。
class AbstractUser < ActiveRecord::Base
  self.abstract_class = true
end
