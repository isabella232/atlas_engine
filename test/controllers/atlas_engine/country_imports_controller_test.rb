# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryImportsControllerTest < ActionDispatch::IntegrationTest
    setup do
      https!
    end

    test "should get index" do
      get "/country_imports"
      assert_response :success
    end

    test "#interrupt invokes interrupt on a country import and redirects with notice upon success" do
      country_import = CountryImport.create!(country_code: "XX", state: :in_progress)
      get "/country_imports/#{country_import.id}/interrupt"

      assert country_import.reload.failed?
      assert_redirected_to(controller: "country_imports", action: "index")
      assert_equal "Country import manually interrupted. Wait a few minutes for ongoing jobs to stop.", flash[:notice]
    end

    test "#interrupt invokes interrupt on a country import and redirects with alert upon failure" do
      country_import = CountryImport.create!(country_code: "XX", state: :complete)
      get "/country_imports/#{country_import.id}/interrupt"

      assert_not country_import.reload.failed?
      assert_redirected_to(controller: "country_imports", action: "index")
      assert_equal "Interruption of country import failed with StateMachines::InvalidTransition, "\
        "Cannot transition state via :interrupt from :complete (Reason(s): State cannot transition via \"interrupt\")",
        flash[:alert]
    end
  end
end
