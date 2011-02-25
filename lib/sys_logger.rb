require 'singleton'
require 'syslog'
require 'logger'
require 'socket'

module Hejia
  class SysLogger
    include Singleton

    LEVEL_NAMES_MAP = {
      'error'   => 'err',
      'warn'    => 'warning',
      'unknown' => 'notice',
      'fatal'   => 'crit'
    }

    LEVEL_MAP = Hash.new(Logger::UNKNOWN).update(
      Syslog::LOG_DEBUG   => Logger::DEBUG,
      Syslog::LOG_INFO    => Logger::INFO,
      Syslog::LOG_WARNING => Logger::WARN,
      Syslog::LOG_ERR     => Logger::ERROR,
      Syslog::LOG_CRIT    => Logger::FATAL,
      Syslog::LOG_NOTICE  => Logger::UNKNOWN
    )

    LEVEL_METHODS = Hash.new(Syslog::LOG_DEBUG).update(
      Syslog::LOG_DEBUG   => :debug,
      Syslog::LOG_INFO    => :info,
      Syslog::LOG_NOTICE  => :notice,
      Syslog::LOG_WARNING => :warning,
      Syslog::LOG_ERR     => :err,
      Syslog::LOG_ALERT   => :alert,
      Syslog::LOG_CRIT    => :crit,
      Syslog::LOG_EMERG   => :emerg
    )

    class << self
      def identifier=(ident)
        @identifier = "#{ident}:#{Socket.gethostname}"
      end
      alias app= identifier=

      def identifier
        @identifier ||= "#{Socket.gethostname}:#{$0}"
      end
      alias app identifier
    end

    attr_reader :level

    def initialize
      open!
      self.level = 'debug'
    end

    # :nodoc:
    # @level 是用来兼容Logger的；
    # @mask  是Syslog使用的。
    def level=(level)
      if level.is_a?(Integer)
        @level = level
        mask = LEVEL_MAP.detect { |_, l| l == level }
        @mask = mask ? mask.first : Syslog::LOG_EMERG
      else
        level = (level || 'debug').to_s.downcase
        level = LEVEL_NAMES_MAP[level] if LEVEL_NAMES_MAP.has_key?(level)
        @mask  = Syslog.const_get("LOG_#{level.to_s.upcase}")
        @level = LEVEL_MAP[@mask]
      end
      set_mask
    end

    def add(level, message)
      level_map = LEVEL_MAP.detect { |k, v| v == level }
      level = level_map ? level_map.first : Syslog::LOG_DEBUG
      send LEVEL_METHODS[level], message
    end

    %w[debug info notice err warning crit alert emerg].each do |method|
      class_eval <<-_CODE_
      def #{method}(text = nil)
        text = text || block_given? && yield
        Syslog.#{method} '[#{method.upcase}] %s', text if text
      end

      def #{method}?
        can_log? Syslog::LOG_#{method.upcase}
      end
      _CODE_
    end

    LEVEL_NAMES_MAP.each do |alias_as, method|
      alias_method alias_as, method
      alias_method "#{alias_as}?", "#{method}?"
    end

    # 纯粹为了兼容rails原来的logger。
    class << self; attr_accessor :silencer end
    self.silencer = true

    def silencer;            self.class.silencer            end
    def silencer=(silencer); self.class.silencer = silencer end

    def silence(temporary_level = Logger::ERROR)
      if silencer
        begin
          mask = LEVEL_MAP.detect { |_, lev| lev == temporary_level }
          mask = mask ? mask.first : Syslog::LOG_EMERG
          old_mask, @mask = @mask, mask
          set_mask
          yield self
        ensure
          @mask = old_mask
          set_mask
        end
      else
        yield self
      end
    end

    private

    def open!
      close
      Syslog.open self.class.identifier
      set_mask if @mask
    end

    def close
      Syslog.close if Syslog.opened?
    end

    def set_mask
      Syslog.mask = Syslog.LOG_UPTO(@mask) if Syslog.opened?
    end

    def can_log?(level)
      !(Syslog.mask < Syslog.LOG_UPTO(level))
    end

  end
end
