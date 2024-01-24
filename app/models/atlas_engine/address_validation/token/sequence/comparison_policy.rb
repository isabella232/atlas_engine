# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        class ComparisonPolicy
          extend T::Sig

          UNMATCHED_POLICIES = [
            :retain,                        # keep all unmatched tokens in comparison
            :ignore_left_unmatched,         # omit unmatched tokens from left sequence in comparison
            :ignore_right_unmatched,        # omit unmatched tokens from right sequence in comparison
            :ignore_largest_unmatched_side, # omit unmatched tokens from the side with the most unmatched tokens,
            # omit from left in case of a tie
          ].freeze

          attr_reader :unmatched

          sig { params(unmatched: Symbol).void }
          def initialize(unmatched:)
            raise "Unknown unmatched policy: #{unmatched}" if UNMATCHED_POLICIES.exclude?(unmatched)

            @unmatched = unmatched
          end

          DEFAULT_POLICY = ComparisonPolicy.new(unmatched: :retain).freeze
        end
      end
    end
  end
end
