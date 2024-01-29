# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pt
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        STREET = "(?<street>.+)"
        NUMBERED_STREET = "(?<street>.+\s+[0-9]+)"
        BUILDING_NUM = "n?(?<building_num>[0-9]+[a-z]*)"
        UNIT_NUM = "(?<unit_num>[[:alnum:]]+)"
        DIRECTION = /\b(?<direction>esq|dir|dto|fte|e|d|f|esquerda|direito|frente|fundo|andar)\b\.?/i
        PO_BOX = /\b(?<box_type>ap|apartado|caixa postal|cp)\s+(?<number>\d+)\b/i

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET},?\s+#{BUILDING_NUM}$/,
            /^#{STREET},?\s+#{BUILDING_NUM},?\s.*$/,
            /^#{NUMBERED_STREET},?\s+#{BUILDING_NUM}$/,
            /^#{STREET},?\s+#{BUILDING_NUM}[\s,-]+#{UNIT_NUM}$/,
            /^#{STREET},?\s+#{BUILDING_NUM}[\s,-]+#{UNIT_NUM}[\s,-]+#{DIRECTION}$/,
            /^#{NUMBERED_STREET},?\s+#{BUILDING_NUM}[\s,-]+#{UNIT_NUM}$/,
            /^#{NUMBERED_STREET},?\s+#{BUILDING_NUM}[\s,-]+#{UNIT_NUM}[\s,-]+#{DIRECTION}$/,
          ]
        end

        sig { override.params(address_line: String).returns(T::Array[T.nilable(String)]) }
        def extract_po_box(address_line)
          po_box_match = address_line.match(PO_BOX)

          if po_box_match
            po_box = po_box_match["number"]
            address_line = address_line.gsub(PO_BOX, "").strip.delete_suffix(",")
          else
            po_box = nil
          end

          [address_line, po_box]
        end

        # Return true if something's obviously wrong with this regex match
        sig do
          override.params(
            captures: T::Hash[Symbol, T.nilable(String)],
            address: ::AtlasEngine::AddressValidation::AbstractAddress,
          ).returns(T::Boolean)
        end
        def ridiculous?(captures, address)
          building_num = captures[:building_num]&.downcase
          street = captures[:street]&.downcase
          unit_num = captures[:unit_num]&.downcase

          if street.present?
            return true unless address.address1&.upcase&.include?(street.upcase) ||
              address.address2&.upcase&.include?(street.upcase)
          end

          [building_num, unit_num].any? do |token|
            po_box?(token) || street_suffix?(token)
          end
        end

        sig { override.params(token: T.nilable(String)).returns(T::Boolean) }
        def po_box?(token)
          return false if token.blank?

          token.match?(PO_BOX)
        end
      end
    end
  end
end
