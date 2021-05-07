require 'base64'

class LogStash::Util::PlainConverter
  attr_accessor :logger

  def initialize(charset)
    @charset = charset
    @charset_encoding = Encoding.find(charset)
  end

  def convert(data)
    data.force_encoding(@charset_encoding)

    # if charset is BINARY, it out as it is.
    return data if is_charset_binary

    # NON UTF-8 charset declared.
    # Let's convert it (as cleanly as possible) into UTF-8 so we can use it with JSON, etc.
    return data.encode(Encoding::UTF_8, :invalid => :replace, :undef => :replace) unless @charset_encoding == Encoding::UTF_8

    # UTF-8 charset declared.
    # Some users don't know the charset of their logs or just don't know they
    # can set the charset setting.
    unless data.valid_encoding?
      # A silly hack to help convert some of the unknown bytes to
      # somewhat-readable escape codes. The [1..-2] is to trim the quotes
      # ruby puts on the value.
      ret = data.inspect[1..-2].tap do |escaped|
        @logger.warn("Received an event that has a different character encoding than you configured.", :text => escaped, :expected_charset => @charset)
      end
      ret.force_encoding(Encoding::UTF_8)
      return ret
    end

    return data
  end
  # def convert

  def is_charset_binary
    @charset_encoding == Encoding::BINARY
  end
end
# class LogStash::Util::Base64Converter
