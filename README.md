# Atlas Engine

Atlas Engine is a rails engine that provides a global end-to-end address validation API for rails apps.

The validation API is powered by GraphQL, an example request and explanation of the parameters and response follows:

```
query validation {
  validation(
    address: {
      address1: "151 O'Connor St"
      address2: ""
      city: "Ottawa"
      provinceCode: "ON"
      countryCode: CA
      zip: "K2P 2L8"
    }
    locale: "en"
    matchingStrategy: LOCAL
  ) {
    validationScope
    concerns {
      code
      fieldNames
      suggestionIds
      message
    }
    suggestions {
      address1
      address2
      city
      provinceCode
      zip
    }
  }
}
```

Response:

```
{
  "data": {
    "validation": {
      "validationScope": [
        "country_code",
        "province_code",
        "zip",
        "city",
        "address1"
      ],
      "concerns": [],
      "suggestions": []
    }
  }
}
```

*Address:* The raw input for each address line that is to be validated. Requirements for each field's format and even
presence or absence differs per country.

*Locale:* The language in which to render any messages in the validation API response.

*MatchingStrategy:* The strategy used to evaluate the validity of the address input. Out of the box, Atlas Engine
supports three different matching strategies: `local`, `es`, and `es_street`.
  - `local` matching uses the [worldwide](https://github.com/Shopify/worldwide) gem to provide the most basic level of
  address validation. This may include simple errors (required fields not populated) or more advanced errors (province
  not belonging to the country, zip code not belonging to the province). This level of matching does not require
  [ingestion](#ingestion) of country data to work, but the level of support and suggestions it can provide in its
  responses is minimal.
  - `es` matching uses data indexed in elasticsearch via our [ingestion](#ingestion) process to validate the city,
  province, country, and zip code fields of the input address, in addition to all of the basic functionality provided
  in the `local` strategy. A more detailed explanation for how this strategy works can be found [here](#elasticsearch-matching-strategy).
  - `es_street` is our most advanced matching strategy and requires the highest quality data indexed in elasticsearch
  via our [ingestion](#ingestion) process. This matching strategy provides everything that `es` and `local` does along
  with validation of the address1 and address2 components of the address input. A more detailed explanation of how
  this strategy works can be found [here](#elasticsearch-matching-strategy).

*Validation Scope*: This response object is populated with the field names from the input that have been successfully
validated.

*Concerns:* This response object is populated with a code if there is a validation error with the input address.
A concern may also include a suggestion to fix the issue.

*Suggestions:* This response object provides the corrected value for a field that has a concern if available.

### Example request with a concern:

Navigate to http://localhost:3000/graphiql and initiate the following request. Note the invalid zip field.

```
query validation {
  validation(
    address: {
      address1: "151 O'Connor St"
      address2: ""
      city: "Ottawa"
      provinceCode: "ON"
      countryCode: CA
      zip: "90210"
    }
    locale: "en"
    matchingStrategy: LOCAL
  ) {
    validationScope
    concerns {
      code
      fieldNames
      suggestionIds
      message
    }
    suggestions {
      address1
      address2
      city
      provinceCode
      zip
    }
  }
}
```

Response:

```
{
  "data": {
    "validation": {
      "validationScope": [
        "country_code",
        "province_code",
        "city",
        "address1"
      ],
      "concerns": [
        {
          "code": "zip_invalid_for_province",
          "fieldNames": [
            "zip",
            "country",
            "province"
          ],
          "suggestionIds": [],
          "message": "Enter a valid postal code for Ontario"
        }
      ],
      "suggestions": []
    }
  }
}
```

The concerns object contains a concern code `zip_invalid_for_province` to highlight the validation error of `90210`
being an invalid zip code for the province `ON`. It also returns the human readable message
`"Enter a valid postal code for Ontario"` in the provided language `en`.

The validation scope excludes zip because the zip was not successfully validated.

## Installation of Atlas Engine in your rails app

### Initial setup
Add the engine to your gemfile
```
gem "atlas_engine"
```

Run the following commands to install the engine in your rails app

```
bundle lock
bin/rails generate atlas_engine:install
```

### Updating to a newer version of the engine

Working with migrations
```
# Copy any migrations from the engine into your app
rails atlas_engine:install:migrations

# Perform the migrations in your app
rails db:migrate
```

## Setup Atlas Engine for contribution / local development

This setup guide is based on a mac os development environment. Your tooling may vary.

### Install + Setup Docker

```
brew install docker
brew install docker-compose

# to setup the docker daemon
brew install colima

# to start the docker daemon
colima start --cpu 4 --memory 8
colima ssh
  sudo sysctl -w vm.max_map_count=262144
  exit
```

Verify docker is running with: `docker info`

### Clone the atlas_engine git repository

```
git clone https://github.com/Shopify/atlas-engine.git
```

### Setup Ruby and Rails

Install ruby >= 3.2.1

In the newly cloned repository directory run:

```
bundle install

# *Note* If you get an ssl error during the puma installation run the following command:
bundle config build.puma --with-pkg-config=$(brew --prefix openssl@3)/lib/pkgconfig
```

### Setup up Dockerized Elasticsearch and MySQL

In a separate terminal, from the cloned atlas_engine directory run:
```
bash setup
docker-compose up

# *Note* If you encounter an error getting docker credentials, remove or update the `credsStore`
key in your Docker configuration file:

# ~/.docker/config.json
"credsStore": "desktop", # remove this line
```

Verify your connection to the newly created Docker services with the following commands:
  - MySQL : `mysql --host=127.0.0.1 --user=root`
  - Elasticsearch : `curl http://localhost:9200`

### Setup the local db
```
rails db:setup
```

### Infrastructure Requirements
The elasticsearch implementation depends on the ICU analysis plugin. Refer to the [Dockfile](./Dockfile) leveraged in local setup for plugin installation.

### Starting the App / Running Tests
  * `bin/rails server` to start the server
  * `bin/rails test` to run tests
  * `bundle exec rubocop` to run ruby style checks
  * `src tc` to run sorbet typechecks

### Sorbet

Generate rbi files for custom code
```
bin/tapioca dsl --app-root="test/dummy/"
```

Generate rbi files for gems
```
bin/tapioca gems

# or

bin/tapioca gems --all
```

Run sorbet check
```
srb tc
```

## Ingestion

In order to power the more advanced validation matching strategies that provide city / state / zip and even street
level address validation, your app must have a populated elasticsearch index per country available for `atlas_engine`
to query.

The data we use to power atlas engine validation is free open source data from the [open addresses](https://openaddresses.io/)
project. The following guide demostrates how to ingest data with the dummy app, but the process is the same with
the engine mounted into your own rails app.

1. Go to the [open addresses](https://openaddresses.io/) download center, create an account, support the project, and
download a GeoJSON+LD file for the country or region you wish to validate. For this example, we will be using the
countrywide addresses data for Australia.

2. Once the file is downloaded, start your app with `rails s` and navigate to `http://localhost:3000/maintenance_tasks`
(see [the github repo](https://github.com/Shopify/maintenance_tasks) for more information about maintenance_tasks).
There are two tasks available: `Maintenance::AtlasEngine::GeoJsonImportTask` and `Maintenance::AtlasEngine::ElasticsearchIndexCreateTask`. We will be using both in the ingestion process.

3. Navigate to the `Maintenance::AtlasEngine::GeoJsonImportTask`. This task will transform the raw geo json file into
records in our mysql database and has the following parameters:

clear_records: If checked, removes any existing records for the country in the database.

country_code: (required) The ISO country code of the data we are ingesting.
In this example, the country code of Australia is `AU`.

geojson_file_path: (required) The fully qualified path of the previously downloaded geojson data from open addresses.

locale: (optional) The language of the data in the open addresses file.

4. Once properly parameterized, click run. The process will initialize a `country_import` and should succeed immediately.

5. Navigate to `http://localhost:3000/country_imports` to track the progress of the country import. Click the import id
link for a more detailed view. Once the import status has updated from `in_progress` to `complete` we will have all of
the raw open address data imported into our mysql database's `atlas_engine_post_addresses` table.

6. Navigate back to `http://localhost:3000/maintenance_tasks` and click on the `Maintenance::AtlasEngine::ElasticsearchIndexCreateTask`. This task will ingest the data we have staged in mysql
and use it to create documents in a new elasticsearch index which Atlas Engine will ultimately use for validation.

7. The `ElasticsearchIndexCreateTask` includes the following parameters:

country_code: (required) the ISO country code of the data we are ingesting and the name of the elasticsearch index we
will be creating. In this example, the country code of Australia is `AU`.

locale: (optional) the language of the documents we will be creating. This is required for multi-locale countries
as our indexes are separated by language.

province_codes: (optional) an allow list of province codes to create documents for. If left blank the task will create
documents for the entire dataset.

shard_override: (optional) the number of shards to create this index with. If left blank the default will be used.

replica_override: (optional) the number of replicas to create this index with. If left blank the default will be used.

activate_index: (optional) if checked, immediately promote this index to be the index queried by atlas engine.
If unchecked, the created index will need to be activated manually.

8. Once properly parameterized, click run. The maintenance task UI will track the progress of the index creation.

9. When completed, the index documents may be verified manually with an elasticsearch client.
We may now use the `es` and `es_street` matching strategies with `AU` addresses. See [below](#elasticsearch-matching-strategy)
for an example of its usage.

## Elasticsearch Matching Strategy

Once we have successfully created and activated an elasticsearch index using open address data, we may now use
the more advanced elasticsearch matching strategies `es` and `es_street`.

Consider the following example of an invalid `AU` address:

```
query validation {
  validation(
    address: {
      address1: "100 miller st"
      address2: ""
      city: "sydney"
      provinceCode: "NSW"
      countryCode: AU
      zip: "2060"
    }
    locale: "en"
    matchingStrategy: ES
  ) {
    validationScope
    concerns {
      code
      fieldNames
      suggestionIds
      message
    }
    suggestions {
      address1
      address2
      city
      provinceCode
      zip
    }
  }
}
```

When input into `http://localhost:3000/graphiql`, this query should produce the following response:

```
{
	"data": {
		"validation": {
			"candidate": ",NSW,,,,2060,[North Sydney],,Miller Street",
			"validationScope": [
				"country_code",
				"province_code",
				"zip",
				"city",
				"address1"
			],
			"concerns": [
				{
					"code": "city_inconsistent",
					"typeLevel": 3,
					"fieldNames": [
						"city"
					],
					"suggestionIds": [
						"665ffd09-75b8-584d-8e4a-a0f471bfea01"
					],
					"message": "Enter a valid city for New South Wales, 2060"
				}
			],
			"suggestions": [
				{
					"id": "665ffd09-75b8-584d-8e4a-a0f471bfea01",
					"address1": null,
					"address2": null,
					"city": "North Sydney",
					"province": null,
					"provinceCode": null,
					"zip": null
				}
			]
		}
	}
}
```

The concerns object contains a concern code `city_inconsistent` to highlight the validation error of `sydney`
being an incorrect city for the rest of the provided address. The concern message field is the human readable
error nudge `"Enter a valid city for New South Wales, 2060"`, pointing to the supporting pieces of evidence (province
and zip) that were used to determine city as the inconsistent value in this address input.

The suggestion object contains a corrected city field `North Sydney` which will result in no concerns or suggestions
for the validation endpoint if applied.

The candidate field contains a representation of the matching document in the elasticsearch index that was found and
used to determine the suggestions and concerns in the api response.

The `es_street` level of validation can also be used to correct errors in the `address1` or `address2` fields of the
input. In the following request we have modified our query to make a second error in our input - searching for
`miller ave` instead of `miller st`.

```
query validation {
  validation(
    address: {
      address1: "100 miller ave"
      address2: ""
      city: "sydney"
      provinceCode: "NSW"
      countryCode: AU
      zip: "2060"
    }
    locale: "en"
    matchingStrategy: ES_STREET
  ) {
    validationScope
    concerns {
      code
      fieldNames
      suggestionIds
      message
    }
    suggestions {
      address1
      address2
      city
      provinceCode
      zip
    }
  }
}
```

This query produces the following response:

```
{
	"data": {
		"validation": {
			"candidate": ",NSW,,,,2060,[North Sydney],,Miller Street",
			"validationScope": [
				"country_code",
				"province_code",
				"zip",
				"city",
				"address1"
			],
			"concerns": [
				{
					"code": "city_inconsistent",
					"typeLevel": 3,
					"fieldNames": [
						"city"
					],
					"suggestionIds": [
						"88779db6-2c5d-5dbb-9f77-f7b07c07206a"
					],
					"message": "Enter a valid city for New South Wales, 2060"
				},
				{
					"code": "street_inconsistent",
					"typeLevel": 3,
					"fieldNames": [
						"address1"
					],
					"suggestionIds": [
						"88779db6-2c5d-5dbb-9f77-f7b07c07206a"
					],
					"message": "Enter a valid street name for New South Wales, 2060"
				}
			],
			"suggestions": [
				{
					"id": "88779db6-2c5d-5dbb-9f77-f7b07c07206a",
					"address1": "100 Miller Street",
					"address2": null,
					"city": "North Sydney",
					"province": null,
					"provinceCode": null,
					"zip": null
				}
			]
		}
	}
}
```

The concerns object now contains an additional concern code `street_inconsistent` to highlight the validation error of
`miller ave` being an incorrect street for the rest of the address input. The concern message field is the human
readable error nudge `"Enter a valid street name for New South Wales, 2060"`, pointing to the supporting pieces of
evidence (province and zip) that were used to determine street as an inconsistent value in this address input.

The suggestion object contains a corrected street field `100 Miller Street` and a corrected city field `North Sydney`
If both of these suggestions are applied to the input address the subsequent request will be valid.

The corrected input of

```
query validation {
  validation(
    address: {
      address1: "100 miller st"
      address2: ""
      city: "north sydney"
      provinceCode: "NSW"
      countryCode: AU
      zip: "2060"
    }
    locale: "en"
    matchingStrategy: ES_STREET
  ) {
    validationScope
    concerns {
      code
      fieldNames
      suggestionIds
      message
    }
    suggestions {
      address1
      address2
      city
      provinceCode
      zip
    }
  }
}
```

will produce the response:

```
{
	"data": {
		"validation": {
			"candidate": ",NSW,,,,2060,[North Sydney],,Miller Street",
			"validationScope": [
				"country_code",
				"province_code",
				"zip",
				"city",
				"address1"
			],
			"concerns": [],
			"suggestions": []
		}
	}
}
```

This response has no concerns or suggestions, and the input address is therefore considered to be valid.
