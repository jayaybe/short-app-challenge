require 'uri'
require 'nokogiri'
require 'open-uri'


class ShortUrl < ApplicationRecord

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validate :validate_full_url

  def short_code
    #Base62 encoding, based on characters
    encode_url(id)
  end

  def update_title!
    begin
      title = Nokogiri::HTML.parse(open(full_url)).title
      update(title: title)
    rescue StandardError
      errors.add(:full_url, :invalid_url, "Unable to access URL")
    end
  end

  def as_json(options={})
    super(methods: :short_code)
  end

  def public_attributes
    as_json
  end

  #pull these out into a helper?
  def encode_url(num)
    return nil if num == nil

    code = ""
    length = CHARACTERS.length
    while(num > 0) do
      code = CHARACTERS[num % length] + code
      num = num / length
    end
    code
  end

  def self.decode_url(code)
    return nil if code == nil

    num = 0
    length = CHARACTERS.length
    code.to_s.each_char do |letter|
      num = (num * length) + CHARACTERS.index(letter)
    end
    num
  end

  scope :find_by_short_code, -> (short_code){ find(ShortUrl.decode_url(short_code)) }

  private

  def validate_full_url
    if full_url.nil? || full_url.empty?
      errors.add(:full_url, :blank_url, message: "can't be blank")
      return
    end

    begin
      uri = URI.parse(full_url)
      errors.add(:full_url, :invalid_url, message: "Full url is not a valid url") if uri.host.to_s.blank?
    rescue StandardError
      errors.add(:full_url, :invalid_url, message: "is not a valid url")
    end
  end

end
