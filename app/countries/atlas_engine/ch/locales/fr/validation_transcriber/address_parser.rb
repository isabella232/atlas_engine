# typed: true
# frozen_string_literal: true

# French address in Switzerland can be written in the following ways:
# 1. thoroughfare type[ ]Thoroughfare name[ ]number
# 2. number[ ]thoroughfare type[ ]Thoroughfare name

module AtlasEngine
  module Ch
    module Locales
      module Fr
        module ValidationTranscriber
          class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
            private

            sig { returns(T::Array[Regexp]) }
            def country_regex_formats
              @country_regex_formats ||=
                [
                  /^#{BUILDING_NUM}?\s*#{STREET_NO_COMMAS}$/o,
                  /^#{STREET_NO_COMMAS}?\s*#{BUILDING_NUM}$/o,
                ]
            end
          end
        end
      end
    end
  end
end
