# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

$:.push(File.dirname(__FILE__))

$KCODE = 'UTF-8' unless RUBY_VERSION >= '1.9.0'

require 'yaml'
require 'date'
require 'time'
require 'forwardable'

require 'version'

# patches for extending Ruby functionality
require 'ext/localized_object'
require 'ext/calendars/datetime'
require 'ext/calendars/date'
require 'ext/calendars/time'
require 'ext/numbers/localized_number'
require 'ext/numbers/bignum'
require 'ext/numbers/fixnum'
require 'ext/numbers/float'
require 'ext/strings/symbol'
require 'ext/strings/string'

require 'utils'

# manages access to CLDR resources (yaml files in resources dir)
require 'shared/resources'


module TwitterCldr

  extend SingleForwardable

  DEFAULT_LOCALE = :en
  DEFAULT_CALENDAR_TYPE = :gregorian
  RESOURCE_DIR = File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), "resources")

  # maps twitter locales to cldr locales
  TWITTER_LOCALE_MAP = { :msa     => :ms,
                         :'zh-cn' => :zh,
                         :'zh-tw' => :'zh-Hant' }

  @@resources = TwitterCldr::Shared::Resources.new

  def_delegator :resources, :resource_for, :get_resource

  class << self

    def get_resource_file(locale, resource)
      File.join(RESOURCE_DIR, convert_locale(locale).to_s, "#{resource}.yml")
    end

    def resources
      @@resources
    end

    def get_locale
      if defined?(FastGettext)
        locale = FastGettext.locale
        locale = DEFAULT_LOCALE if locale.to_s.empty?
      else
        locale = DEFAULT_LOCALE
      end

      (supported_locale?(locale) ? locale : DEFAULT_LOCALE).to_sym
    end

    def convert_locale(locale)
      locale = locale.to_sym
      TWITTER_LOCALE_MAP.include?(locale) ? TWITTER_LOCALE_MAP[locale] : locale
    end

    def supported_locales
      unless defined?(@@supported_locales)
        rejectable = [:shared]
        @@supported_locales = Dir.glob(File.join(File.dirname(File.dirname(__FILE__)), "resources/*")).map do |file|
          File.basename(file).to_sym
        end.reject { |file| rejectable.include?(file) }
      end

      @@supported_locales
    end

    def supported_locale?(locale)
      locale = locale.to_sym
      supported_locales.include?(locale) || supported_locales.include?(convert_locale(locale))
    end

  end

end


# other shared libraries (most access shared resource data in resources/shared)
require 'shared/currencies'
require 'shared/languages'
require 'shared/unicode_data'

# all tokenizers
require 'tokenizers/base'
require 'tokenizers/key_path'
require 'tokenizers/token'
require 'tokenizers/composite_token'
require 'tokenizers/calendars/datetime_tokenizer'
require 'tokenizers/calendars/date_tokenizer'
require 'tokenizers/calendars/time_tokenizer'
require 'tokenizers/numbers/number_tokenizer'

# all formatters
require 'formatters/base'
require 'formatters/calendars/datetime_formatter'
require 'formatters/calendars/date_formatter'
require 'formatters/calendars/time_formatter'
require 'formatters/numbers/number_formatter'
require 'formatters/numbers/decimal_formatter'
require 'formatters/numbers/currency_formatter'
require 'formatters/numbers/percent_formatter'
require 'formatters/plurals/plural_formatter'
require 'formatters/plurals/rules'

# formatter helpers
require 'formatters/numbers/helpers/base'
require 'formatters/numbers/helpers/fraction'
require 'formatters/numbers/helpers/integer'

# all normalizers
require 'normalizers/base'
require 'normalizers/canonical/nfd'
