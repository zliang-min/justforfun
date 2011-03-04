# encoding: utf-8
# @author 梁智敏

module Collection
  # 集合基类
  class Base < ActiveRecord::Base
    self.abstract_class = true
  end
end
