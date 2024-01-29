# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Si
    module AddressImporter
      module OpenAddress
        class Mapper < AtlasEngine::AddressImporter::OpenAddress::DefaultMapper
          sig do
            params(feature: AtlasEngine::AddressImporter::OpenAddress::Feature).returns(T::Hash[Symbol, T.untyped])
          end
          def map(feature)
            super(feature).merge(region4: feature["properties"]["district"])
          end
        end
      end
    end
  end
end
