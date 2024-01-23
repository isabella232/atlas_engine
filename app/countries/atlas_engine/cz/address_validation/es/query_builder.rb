# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Cz
    module AddressValidation
      module Es
        class QueryBuilder < AtlasEngine::AddressValidation::Es::DefaultQueryBuilder
          private

          sig { returns(Hash) }
          def street_clause
            street_queries = [build_street_queries, empty_street_clause]

            {
              "dis_max" => {
                "queries" => street_queries.flatten,
              },
            }
          end

          sig { returns(Hash) }
          def empty_street_clause
            {
              "bool" => {
                "must_not" => {
                  "exists" => {
                    "field" => "street",
                  },
                },
              },
            }
          end

          sig { returns(T::Array[String]) }
          def street_query_values
            street_names.presence || []
          end
        end
      end
    end
  end
end
