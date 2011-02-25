require 'sequel/extensions/migration'

class RubyAnalytics
  module DB
    class Schema < Sequel::Migration
      def up
        create_table? :page_tracks do
          primary_key :id
          Integer :view_code
          String :session
          String :ip, :size => 15
          String :account
          String :browser_language
          String :browser_language_encoding
          String :referral
          String :referrer
          String :screen_resolution
          String :screen_color_depth
          String :flash_version
          String :page
          String :page_title
          String :host_name
          String :user_agent
          String :campaign_source
          String :campaign_medium
          String :campaign_term
          String :campaign_content
          String :campaign_name
          String :viewed_at,        :size => 20
          String :visited_at,       :size => 20
          String :first_visit_time, :size => 20
          String :last_visit_time,  :size => 20
          Boolean :java_enabled
        end
      end
    end

    def self.migrate connection
      Schema.apply connection, :up
    end
  end
end
