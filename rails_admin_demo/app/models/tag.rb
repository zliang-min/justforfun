# encoding: utf-8
# @author 梁智敏

# 标签
# @设计意图
#   标签是一个通用的概念，用来给任何对象的任何属性进行分类。
#   所以，一个品牌、一个行业、文章的类型，等等，都可以是标签。
#   标签本身也可以通过标签来分类，从而实现标签自己的树状（网状）结构。
class Tag < ActiveRecord::Base
  # Tag.taged_with('品牌')
  # Tag.roots = Tag.tagged_with(nil) = Tag.not_tagged
end
