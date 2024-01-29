# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pt
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        test "One line Portugal addresses" do
          [
            # standard format with building number
            [:pt, "Rua da Liberdade 17", [{ street: "Rua da Liberdade", building_num: "17" }]],
            # street has accented character
            [:pt, "Avenida da República 8", [{ street: "Avenida da República", building_num: "8" }]],
            # building and unit number separated by comma
            [:pt, "Avenida do Mar 18, 1C", [{ street: "Avenida do Mar", building_num: "18", unit_num: "1C" }]],
            # alphanumeric building number
            [:pt, "Rua Maria Matos, 15rc", [{ street: "Rua Maria Matos", building_num: "15rc" }]],
            # street with building number, floor number and direction
            [
              :pt,
              "Praceta de Alvalade 5, 4 direito",
              [
                { street: "Praceta de Alvalade 5", building_num: "4", unit_num: "direito" },
                { street: "Praceta de Alvalade", building_num: "5", unit_num: "4", direction: "direito" },
              ],
            ],
            # street with extra information
            [:pt, "Travessa do Fojo, 14, Este S. Mamede", [{ street: "Travessa do Fojo", building_num: "14" }]],
            # steet with building number designator
            [:pt, "Travessa são Cristóvão n62", [{ street: "Travessa são Cristóvão", building_num: "62" }]],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line Portugal addresses" do
          [
            # building number on address2
            [:pt, "Avenida da Boavista", "22", [{ street: "Avenida da Boavista", building_num: "22" }]],
            # numbered street with building number, unit on address2
            [
              :pt,
              "Rua do Ouro 116",
              "3º Esq.",
              [
                { street: "Rua do Ouro", building_num: "116" },
                { street: "Rua do Ouro", building_num: "116", unit_num: "3º", direction: "Esq" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        test "Isolates Portugal post office boxes" do
          [
            [:pt, "Apartado 1234", nil, [{ po_box: "1234" }]],
            [:pt, "AP 12345", nil, [{ po_box: "12345" }]],
            [:pt, "Caixa Postal 123", nil, [{ po_box: "123" }]],
            [:pt, "cp 123", nil, [{ po_box: "123" }]],
            [
              :pt,
              "Avenida da Boavista 12, ap 1234",
              nil,
              [{ street: "Avenida da Boavista", building_num: "12", po_box: "1234" }],
            ],
            [
              :pt,
              "Avenida da Boavista 12",
              "ap 1234",
              [{ street: "Avenida da Boavista", building_num: "12", po_box: "1234" }],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AtlasEngine::AddressValidation::Address.new(**components)

          actual = AddressParser.new(address: address).parse

          assert(
            expected.to_set.subset?(actual.to_set),
            "For input ( address1: #{address1.inspect}, address2: #{address2.inspect} )\n\n " \
              "#{expected.inspect} \n\n" \
              "Must be included in: \n\n" \
              "#{actual.inspect}",
          )
        end
      end
    end
  end
end
