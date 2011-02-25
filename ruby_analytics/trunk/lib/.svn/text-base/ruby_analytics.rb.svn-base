require 'pathname'
require 'logger'

require 'sequel_core'
require 'rack'

class RubyAnalytics

  F = ::File

  EPOCH = Time.utc(1970, 1, 1).freeze
  TIME_STRING_FORMAT = "%Y-%m-%dT%H:%M:%S".freeze

  C_equal        = '='.freeze
  C_dot          = '.'.freeze
  C_plus         = '+'.freeze
  C_semicolon    = ';'.freeze
  C_vertical_bar = '|'.freeze
  C_1            = '1'.freeze

  # set constants for ga variables, e.g.
  # C_utmac = 'utmac'.freeze
  %w[utmac utmul utmcs utmr utmrr utmsr utmsc utmfl utmp utmdt utmhn utmje utmcc __utma __utmz utmcsr utmcmd utmctr utmccn utmcct].each { |name| const_set "C_#{name}", name.freeze }

  @@root = Pathname(__FILE__).dirname.join('..').expand_path.freeze
  def self.root; @@root end

  def self.production_mode?
    ENV['RACK_ENV'] == 'production'
  end

  autoload :DB,   root.join('lib/ruby_analytics/db').to_s
  autoload :File, root.join('lib/ruby_analytics/file').to_s

  def initialize(options={})
    initialize_options options
    initialize_logger
    initialize_file_backend

    @connection = {}
  end

  def call(env)
    request = Rack::Request.new(env)
    track_page_view request if request.path == '/__utm.gif'
    @file_backend.call(env)
  end

  private
    def initialize_options(options)
      @options = {
        # default options go here
        :logger_path  => '/tmp/ra.log',
        :logger_level => Logger::INFO
      }.merge(options || {})
    end

    def initialize_logger
      dir = F.dirname @options[:logger_path]
      unless F.directory?(dir)
        require 'fileutils'
        FileUtils.mkdir_p dir
      end
      @logger = Logger.new @options[:logger_path]
      @logger.level = @options[:logger_level]
    end

    def initialize_file_backend
      exceptions = %w[dispatch.fcgi ra.js]
      exceptions << 'ra.uncompressed.js' if self.class.production_mode?
      @file_backend = File.new self.class.root.join('public'),
        :except => exceptions
    end

    def persistence
      now = Time.now
      key = "#{now.month}.#{now.day}"
      conn = @connection[key]
      if conn.nil?
        @connection.values.each { |c| c.disconnect rescue nil }
        @connection.clear
        @connection[key] = conn = Sequel.connect("sqlite://#{self.class.root + 'db' + "#{now.year}.#{key}.sqlite3"}")
        DB.migrate conn
      end
      conn
    end

    def track_page_view request
      params = request.params
      cookies = params['utmcc']
      return @logger.error "COOKIES is empty! | (#{request.ip})" if cookies.nil? || cookies.empty?

      track = parse_cookies cookies
      return @logger.error "No page track data in cookies! | (#{request.ip})" unless track

      track.merge!(
        :user_agent                => request.user_agent,
        :ip                        => request.ip,
        :account                   => params[C_utmac],
        :browser_language          => params[C_utmul],
        :browser_language_encoding => params[C_utmcs],
        :referral                  => params[C_utmr],
        :referrer                  => params[C_utmrr],
        :screen_resolution         => params[C_utmsr],
        :screen_color_depth        => params[C_utmsc],
        :flash_version             => params[C_utmfl],
        :page                      => params[C_utmp],
        :page_title                => params[C_utmdt],
        :host_name                 => params[C_utmhn],
        :java_enabled              => params[C_utmje].eql?(C_1),
        :viewed_at                 => Time.now.getutc.strftime(TIME_STRING_FORMAT)
      )

      persistence[:page_tracks] << track
    rescue
      @logger.error "#{request.ip} | #{$!.class}: #{$!.message}"
      @logger.error $@.join("\n")
    end

    def parse_cookies cookies
      return if cookies.nil? || cookies.empty?

      cookies = cookies.split(C_plus).inject({}) { |h, cookie|
        cookie.chomp!(C_semicolon)
        k, v = cookie.split C_equal, 2
        h[k] = v
        h
      }

      utma = cookies[C___utma] # e.g. 38597116.18112879.1269858472.1269858472.1269858472.1
      return if utma.nil? || utma.empty?

      result = {}
      utma = utma.split C_dot
      result.update :view_code        => utma[1], # utma[0] is domain hash
                    :first_visit_time => parse_time(utma[2]),
                    :last_visit_time  => parse_time(utma[3]),
                    :visited_at       => parse_time(utma[4]),
                    :session          => utma[5]

      # handle campaign
      if utmz = cookies[C___utmz]
        # something like 38597116.1269858472.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)
        # TODO handle the numbers
        utmz = utmz.split C_dot, 5
        utmz = utmz[-1].split(C_vertical_bar).inject({}) { |h, item|
          k, v = item.split C_equal
          h[k] = v
          h
        }
        result.update :campaign_source  => utmz[C_utmcsr],
                      :campaign_medium  => utmz[C_utmcmd],
                      :campaign_term    => utmz[C_utmctr],
                      :campaign_content => utmz[C_utmcct],
                      :campaign_name    => utmz[C_utmccn]
      end

      result
    end

    def parse_time seconds
      (EPOCH + seconds.to_i).strftime TIME_STRING_FORMAT
    end

end
