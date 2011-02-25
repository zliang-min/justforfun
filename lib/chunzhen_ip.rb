# encoding: utf-8
# @author 梁智敏(Gimi Liang)
# @create at 2011/01/11

# 解释纯真ip数据库，提供通过ip找城市等方法。
# 对数据库的解析是参考：{纯真IP数据库格式详解}[http://lumaqq.linuxsir.org/article/qqwry_format_detail.html]。
# 本程序通过ruby1.8.7, ruby1.9.2测试。
class ChunzhenIp
  HEADER_SIZE = 8
  INDEX_SIZE  = 7

  FILE_ENCODING = 'GBK'

  REDIRECT_MODE_1 = "\x01"
  REDIRECT_MODE_2 = "\x02"

  STRING_TERMINAL = "\000"

  # 数据库中的索引结构。
  # 包含ip（开始ip）和记录的绝对地址。
  Index = Struct.new :ip, :address

  # 数据库中的记录结构。
  # 包含ip（结束ip）和地理位置信息。
  Record = Struct.new :ip, :location

  # 地理位置类。
  class Location
    # 由于纯真ip数据库中的国家、地区名字不规范（中国的省和城市都是报存在国家记录中，连在一起），
    # 所以收录中国所有省份信息，来判断省份和城市信息。
    CHINA_SPECIAL_PROVINCES = %w[北京 上海 天津 重庆 香港 澳门]
    # 数据库中自治区都是用简写的。
    CHINA_PROVINCES = %r/\A#{(%w[
      浙江 安徽 福建 江西 山东 河南 湖北 湖南 广东 海南 四川 河北 贵州   山西
      云南 辽宁 陕西 吉林 甘肃 青海 江苏 台湾 西藏 广西 宁夏 新疆 黑龙江 内蒙古
    ] + CHINA_SPECIAL_PROVINCES).join('|')}/

    CHINESE_CHINA, CHINESE_PROVINCE, CHINESE_CITY = %w[中国 省 市]

    attr_accessor :country, :province, :city, :address

    private_class_method :new

    def self.parse(first_part, second_part)
      location = new

      # 先判断是不是中国地区
      if first_part =~ CHINA_PROVINCES
        location.country, location.province = CHINESE_CHINA, $&
        # 特殊地区，如直辖市，省市同名
        if CHINA_SPECIAL_PROVINCES.include?(location.province)
          location.city = location.province
        else
          location.city = $'.split(CHINESE_PROVINCE).last
          location.city.chomp!(CHINESE_CITY) if location.city
        end
        location.address = second_part
      else
        # 由于数据实在太不规范，只能先将就着。
        location.country  = first_part
        location.province = second_part
      end

      location
    end
  end

  module Utils
    module_function

    def native_encoding_support?
      @is_native_encoding_supported ||= ''.respond_to? :encoding
    end

    # 解释用less sigificant first (little-endian)格式保存的整数。
    # unpack可以比这个方法快若干倍，所以尽可能用unpack。
    def parse_lsf_integer(string)
      index = -1
      string.bytes.inject(0) { |sum, byte|
        sum | byte << 8 * (index += 1)
      }
    end

    def encode_ip(ip)
      times = 4
      ip.split('.').inject(0) { |sum, seg|
        sum + (seg.to_i << 8 * (times -= 1))
      }
    end

    def decode_ip(ip)
      segments = []
      4.times { |n|
        segments.unshift((ip >> 8 * n) - (ip >> 8 * (n + 1) << 8))
      }
      segments.join('.')
    end

    # 字符串转码。
    # 当转码过程发生异常，返回空字符串。
    #--
    # 根据不同的ruby，有不同的版本。
    #++
    if native_encoding_support?
      def encode_string(string, to = 'UTF-8', from = FILE_ENCODING)
        string.encode to, from
      rescue
        puts "Unable encode string#{string.bytes.to_a.inspect} due to #{$!.class}(#$!)"
        string.bytes.to_a.inspect
      end
    else
      require 'iconv'

      def encode_string(string, to = 'UTF-8', from = FILE_ENCODING)
        Iconv.conv to, from, string
      rescue
        puts "Unable encode string#{string.bytes.to_a.inspect} due to #{$!.class}(#$!)"
        string.bytes.to_a.inspect
      end
    end
  end

  # 搜索IP的策略。
  # 可以不断的开发新的策略，来适应不同的应用，或者实现更优秀的算法。
  # 每个策略都是一个module，实现find_record_by_id(ip)的方法，接受一个ip参数，ip是已经编码过的ip；返回值是一个Record对象。
  # 要使用某个策略，就把该module include到ChunzhenIp即可。
  module IPLocateStrategy
    # 二分法搜索
    module BisectionMethod
      def find_record_by_ip(ip)
        head_pos,  end_pos  = index_boundaries
        head_item, end_item = 0, (end_pos - head_pos) / INDEX_SIZE

        record =
          loop do
            item   = head_item + (end_item - head_item) / 2 + (end_item - head_item) % 2
            index  = read_index head_pos + item * INDEX_SIZE
            record = read_record index

            if ip >= index.ip && ip <= record.ip
              break record
            elsif ip < index.ip
              end_item = item - 1
            else
              head_item = item + 1
            end

            break if end_item < head_item
          end
      end
    end # BisectionMethod
  end # IPLocateStrategy

  # 引入要使用的ip搜索算法。
  include IPLocateStrategy::BisectionMethod

  # 使用自带的数据库文件。如果能够提供更新的数据库文件，可以替换掉原来的，也可以直接使用new方法。
  def self.default
    @default_instance ||= new File.expand_path('../../db/qqwry.dat', __FILE__)
  end

  def initialize(db_file)
    self.db_file = db_file
  end

  # 指定ip数据库文件，并更新索引区信息。
  def db_file=(db_file)
    @db_file = db_file.dup.freeze
    read_index_boundaries
  end

  def find_location_by_ip(ip)
    record = find_record_by_ip Utils.encode_ip(ip)
    record && record.location
  end

  def db_version
    read_record last_index
  end

  def print_all_records
    index, pos = 1, index_boundaries.first
    while pos < index_boundaries.last
      ri = read_index pos
      r = read_record ri
      puts "%d) %s : %s , %s , %s, %s" % [index, Utils.decode_ip(ri.ip), Utils.decode_ip(r.ip), r.location.country, r.location.province, r.location.city]
      index += 1
      pos   += INDEX_SIZE
    end
  end

  private

  # ip数据库文件
  attr_reader :db_file
  # 起止索引地址信息
  attr_reader :index_boundaries

  # :stopdoc:
  # :api: private
  def read_file(pos = nil)
    File.open(db_file, 'rb') { |f|
      f.pos = pos if pos
      yield f
    } if block_given?
  end
  # :startdoc:

  # 读取文件头的索引区的起止位置信息，保存在index_boundaries属性中。
  def read_index_boundaries
    @index_boundaries = read_file { |f| f.read HEADER_SIZE }.unpack 'VV'
  end

  def first_index
    read_index index_boundaries.first
  end

  def last_index
    read_index index_boundaries.last
  end

  # 在指定的位置pos读取一条索引信息。
  # @return [Index]
  def read_index(pos)
    read_file(pos) { |f| Index.new read_ip(f), read_address(f) }
  end

  # 读取索引index所指向的记录信息。
  # @return [Record]
  def read_record(index)
    read_file(index.address) { |f| Record.new read_ip(f), read_location(f) }
  end

  # 读取ip。
  def read_ip(io)
    io.read(4).unpack('V').first
  end

  # 读取偏移地址。
  def read_address(io)
    Utils.parse_lsf_integer io.read(3)
  end

  # 读取地理位置信息，包括：国家、地区。
  def read_location(io)
    Location.parse read_contry(io), read_area(io)
  end

  # 读取国家信息
  def read_contry(io)
    contry, flag = '', io.read(1)
    # 地区信息有两种模式：普通和重定向。而重定向又可分为，模式1和模式2两种。
    # *注意* 重定向后，还有可能是重定向。
    case flag
    when REDIRECT_MODE_1
      # 模式1：
      #   ip后的是国家信息的地址，地区信息紧跟着国家信息后。
      io.pos = read_address io
      #contry << read_string(io)
      contry << read_contry(io)
    when REDIRECT_MODE_2
      # 模式2：
      #   ip后的是国家信息的地址，而地区信息是跟在国家偏移地址之后。
      #   所以在读完国家信息后，要把io的地址恢复。
      pos = read_address io
      pos, io.pos = io.pos, pos
      contry << read_contry(io)
      io.pos = pos
    else
      # 最简单的情况，ip后直接是国家和地区的信息。
      contry << read_string(io, flag)
    end
    contry
  end

  # 读取地区信息
  def read_area(io)
    flag = io.read 1
    case flag
    when REDIRECT_MODE_1, REDIRECT_MODE_2
      # 模式1/2：
      #   记录的是地区信息所在的地址。
      io.pos = read_address io
      read_string io
    else
      # 最简单的情况，直接记录地区的信息。
      read_string io, flag
    end
  end

  # 读取字符串内容。
  def read_string(io, buffer = nil)
    string = ''
    buffer ||= io.read 1
    while buffer && buffer != STRING_TERMINAL
      string << buffer
      io.read 1, buffer
    end
    Utils.encode_string string
  end
end

__END__
# 注释掉上面的__END__，然后执行 ruby chunzhen_ip.rb test可以进行测试。
# 执行ruby chunzhen_ip.rb会打印出数据库里面的所有记录。

if __FILE__ == $0
  case ARGV.first
  when 'test'
    ChunzhenIp::Utils.native_encoding_support? or KCODE = 'u'

    require 'rubygems'
    require 'minitest/autorun'

    describe ChunzhenIp do
      attr_reader :file, :db

      before do
        @file = File.expand_path '../../db/qqwry.dat', __FILE__
        @db = ChunzhenIp.new file
      end

      it 'should have sensable index info.' do
        index_boundaries = db.__send__ :index_boundaries
        index_boundaries.first.must_be :<, index_boundaries.last
        index_boundaries.last.must_equal File.size(file) - ChunzhenIp::INDEX_SIZE
      end

      it 'should correctly decode and encode ips.' do
        %w[0.0.0.0 192.168.56.123 255.255.255.255].each { |ip|
          ChunzhenIp::Utils.decode_ip(ChunzhenIp::Utils.encode_ip(ip)).must_equal ip
        }
      end

      it 'should have correct db version.' do
        db_version = db.db_version
        db_version.ip.must_equal ChunzhenIp::Utils.encode_ip('255.255.255.255')
        db_version.location.province.must_match /\d{4}年\d{1,2}月\d{1,2}日/
      end

      it 'should be able to find the correct location for most ips.' do
        [{
          :ip => '58.215.81.154',
          :country => '中国',
          :province => '江苏',
          :city => '无锡'
        }, {
          :ip => '61.177.36.165',
          :country => '中国',
          :province => '江苏',
          :city => '苏州'
        }, {
          :ip => '58.246.26.58',
          :country => '中国',
          :province => '上海',
          :city => '上海'
        }].each do |fixture|
          location = db.find_location_by_ip fixture[:ip]
          location.country.must_equal  fixture[:country]
          location.province.must_equal fixture[:province]
          location.city.must_equal     fixture[:city]
        end
      end
    end
  else
    ChunzhenIp.new(File.expand_path('../qqwry.dat', __FILE__)).print_all_records
  end
end
