# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `AtlasEngine::Types::AddressValidation::AddressInput`.
# Please instead update this file by running `bin/tapioca dsl AtlasEngine::Types::AddressValidation::AddressInput`.

class AtlasEngine::Types::AddressValidation::AddressInput
  sig { returns(T.nilable(::String)) }
  def address1; end

  sig { returns(T.nilable(::String)) }
  def address2; end

  sig { returns(T.nilable(::String)) }
  def city; end

  sig { returns(T.nilable(::String)) }
  def country_code; end

  sig { returns(T.nilable(::String)) }
  def phone; end

  sig { returns(T.nilable(::String)) }
  def province_code; end

  sig { returns(T.nilable(::String)) }
  def zip; end
end
