# encoding: utf-8
# author: 梁智敏

REDIS = $redis = Redis.new(YAML.load(ERB.new(File.read(Rails.root + 'config/redis.yml')).result)[Rails.env].symbolize_keys!.update(:logger => Rails.logger))
