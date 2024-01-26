# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Lu
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        STREET = "(?<street>.+)"
        BUILDING_NUM = "(?<building_num>[0-9]+[[:alpha:]]*)([/-][0-9])?"

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET},?\s+#{BUILDING_NUM}/,
            /^#{BUILDING_NUM}\s?(,\s?)?#{STREET}/,
          ]
        end
      end
    end
  end
end
