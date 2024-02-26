# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class FullAddressStreet < FullAddress
          sig { params(address: TAddress, result: Result).void }
          def initialize(address:, result: Result.new)
            super
            @matching_strategy = MatchingStrategies::EsStreet
          end
        end
      end
    end
  end
end
