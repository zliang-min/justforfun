# encoding: utf-8

$KCODE = 'u' unless ''.respond_to?(:encoding) || $KCODE == 'UTF8'

require 'sqlite3'

class ChineseDictionary

  class << self
    def generate_from_cedict(file)
      File.open(file, 'r') do |file|
        options = {}
        line_no = 1

        db = setup_db

        insert = db.prepare "INSERT INTO #{table_name} (char, sc_char, pinyin) VALUES (?, ?, ?)"
        check  = db.prepare "SELECT count(id) FROM #{table_name} WHERE sc_char = ?"

        chars = 1

        file.each do |line|
          case line
          when setting_pattern
            if line_no < 2
              line_no += 1
            else
              options[$1] = $2.strip!
            end
          when comment_pattern
            next
          else
            char, sc_char, pinyin = line.split space_pattern, 3
            next if sc_char.chars.count > 1
            pinyin = pinyin.match(pinyin_pattern)[1]

            unless check.execute(sc_char).next.first > 0
              insert.execute char, sc_char, pinyin
              $stdout.print "\b" * (chars - 1).to_s.chars.count
              $stdout.print chars
              $stdout.flush
              chars += 1
            end
          end
        end
      end

      puts
      puts 'DONE'
    end

    # 把一串简体中文字符转成拼音。字符串中，非中文字符保持不变。
    # @param [String] sc_words 中文字符串
    # @param [Hash] options 控制拼音生成的额外参数
    # @option [Boolean] :include_phonetic_symbol 是否包括音标，默认是false。
    # @option [String]  :join_with 拼音之间用什么连接符连接，默认没有。
    # @return [String] sc_words中的中文转化成拼音的字符串。
    def pinyin_for(sc_words, options = nil)
      include_phonetic_symbol = options && options[:include_phonetic_symbol]
      join_with = options && options[:join_with]

      sc_words = sc_words.chars.to_a
      result   = db.execute "SELECT sc_char, lower(pinyin) FROM #{table_name} WHERE sc_char in (#{sc_words.map { |c| %('#{c}') }.join ', '})"

      if sc_words.size < 2
        result.empty? ? sc_words.first : (include_phonetic_symbol ? result.first.last : remove_phonetic_symbol(result.first.last))
      else
        result = result.inject({}) { |h, (c, pinyin)| h[c] = include_phonetic_symbol ? pinyin : remove_phonetic_symbol(pinyin); h }
        sc_words.map { |c| result[c] || c }.join join_with
      end
    end

    private

    def setting_pattern
      @@setting_pattern ||= /^#!\s+([^=]+)=(.+)$/.freeze
    end

    def comment_pattern
      @@comment_pattern ||= /^#/.freeze
    end

    def pinyin_pattern
      @@pinyin_pattern  ||= /\[([^\]]+)\]/.freeze
    end

    def space_pattern
      @@space_pattern   ||= /\s+/.freeze
    end

    def phonetic_symbol_pattern
      @@phonetic_symbol_pattern ||= /\d\z/.freeze
    end

    def remove_phonetic_symbol(pinyin)
      pinyin.sub! phonetic_symbol_pattern, ''
    end

    def db
      SQLite3::Database.new db_file
    end

    def db_file
      File.expand_path '../../db/dictionary.db', __FILE__
    end

    def setup_db
      unless File.file?(db_file)
        require 'fileutils'
        FileUtils.mkdir_p File.dirname(db_file)
        FileUtils.touch db_file
      end

      db.tap do |connection|
        connection.table_info(table_name).empty? and
        connection.execute <<_SQL_
CREATE TABLE IF NOT EXISTS #{table_name} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  char CHAR(1) NOT NULL,
  sc_char CHAR(1) NOT NULL,
  pinyin VARCHAR(7) NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS #{table_name}_char_unique_index ON #{table_name}(char);
CREATE UNIQUE INDEX IF NOT EXISTS #{table_name}_sc_char_unique_index ON #{table_name}(sc_char);
_SQL_
      end
    end

    def table_name
      'chinese_dictionary'
    end

    def find_pinyin_statement
      @find_pinyin_statement ||= db.prepare "SELECT lower(pinyin), sc_char FROM #{table_name} WHERE sc_char in ?"
    end
  end

  module StringExtension
    # 把字符串本身转化成对应的拼音。
    # params [Hash] options 参考ChineseDictionary.pinyin_for对 _options_ 参数的说明。
    def to_pinyin(options = nil)
      ChineseDictionary.pinyin_for self, options
    end
  end
end

# 对String扩展
String.__send__ :include, ChineseDictionary::StringExtension
