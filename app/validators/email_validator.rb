# Validates that an attribute is a syntactically well-formed email address
# *with a real, IANA-registered top-level domain* - including
# internationalized (IDN) domains and TLDs, e.g. "m@müller.de" or
# "info@москва.рф".
#
# Plain regexp checks (like the previously used URI::MailTo::EMAIL_REGEXP)
# happily accept nonsense like "a@b.c" or "a@b" because they only check
# shape, not whether the TLD actually exists. This validator additionally
# checks the domain against the public suffix list (via the `public_suffix`
# gem, offline, no network access), so "a@b.c" is rejected while "a@b.de" or
# "a@b.co.uk" are accepted.
#
# Usage:
#   validates :email, email: true
class EmailValidator < ActiveModel::EachValidator
  # Local part: unicode letters/digits and the common RFC 5322 atext
  # special characters, dot-separated (no leading/trailing/double dots).
  ATEXT = "\\p{L}\\p{N}!#$%&'*+\/=?^_`{|}~-"
  LOCAL_PART_REGEXP = /\A[#{ATEXT}]+(?:\.[#{ATEXT}]+)*\z/

  # Domain: dot-separated labels of unicode letters/digits/hyphens, not
  # starting or ending with a hyphen, at least two labels.
  DOMAIN_LABEL = '[\p{L}\p{N}](?:[\p{L}\p{N}-]*[\p{L}\p{N}])?'
  DOMAIN_REGEXP = /\A#{DOMAIN_LABEL}(?:\.#{DOMAIN_LABEL})+\z/

  def validate_each(record, attribute, value)
    return if value.blank?

    local_part, _at, domain = value.rpartition('@')

    if local_part.blank? || domain.blank? ||
        !local_part.match?(LOCAL_PART_REGEXP) || !domain.match?(DOMAIN_REGEXP) ||
        !PublicSuffix.valid?(domain, default_rule: nil)
      record.errors.add(attribute, :invalid)
    end
  end
end
