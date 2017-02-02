require 'spec_helper'

describe Tapir::Reports::Template do
  let(:kitten_photo){ fixture('193px-Stray_kitten_Rambo001.jpg') }

  context "given a document with images in" do
    let(:template) { Tapir::Reports::Template.new(fixture('images.docx')) }

    it "should return the first kitten relationship_id" do
      expect(template.relationship_id('@kitten')).to eq 'rId4'
    end

    it "should return the second kitten relationship_id" do
      expect(template.relationship_id('@kitten2')).to eq 'rId5'
    end

    it "should return the first kitten url" do
      expect(template.url('rId4')).to eq 'word/media/image1.jpg'
    end

    it "should be return a working document" do
      json_string = '{
        "@kitten2" : "https://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg"
      }'
      replacements =
        [
          ['@kitten', fixture('193px-Stray_kitten_Rambo001.jpg')],
          ['@kitten2', 'https://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg'],
        ]
      template.output(json_string, replacements)
#      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end

    it "should complain about missing images" do
      json_string = '{}'
      replacements =
        [
          ['@kitten', fixture('193px-Stray_kitten_Rambo001.jpg')],
        ]
      template.output(json_string, replacements)
    end

    it "should be okay with extra images" do
      json_string = '{}'
      replacements =
        [
          ['@kitten', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_AerialImage.jpg'],
          ['@kitten2', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg'],
          ['@kitten3', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg'],
        ]
      template.write_to_file(json_string, replacements, 'alteredimages.docx')
    end


    it "should do SuDSmart Plus" do
      template = Tapir::Reports::Template.new(fixture('SuDSmart Plus Final v2.0.docx'))

      json_string = '{"id":10,"reference":"51402","status":"in progress","date_issued":"2017-01-12","site_address_single_line":"","site_address_carriage_returned":"","prepared_for_address_single_line":"","prepared_for_address_carriage_returned":"","infiltration_potential_word":"-","surface_water_drainage_potential":"3 low","surface_water_drainage_potential_word":"Low","sewers_potential_word":"Low","overall_flood_risk_word":"Negligible","groundwater_resilience_word":"-","is_groundwater_protected_word":"No","surface_water_resilience_word":"Find protected surface waters - those designated for drinking water abstraction.","ecological_considerations_statement":"The Site is not located within a Special Protected Area (SPA) or a Site of Special Scientific Interest (SSSI).","site_area":"","current_use":"","proposed_use":"","report_author":"Michael Piotrowski","site_easting":"","site_northing":"","infiltration_potential_statement":"Unknown. ESI SuDs data not loaded","topography_statement":"","pollution_statement":"The site is not within a source protection zone, infiltration to the ground is likely to be acceptable providing suitable mitigation measures are in place if required to prevent an impact on water quality from the proposed or historical land use and contaminated land.","surface_water_drainage_statement":"The site is \u003e100m from a surface water body. Discharge to surface water is unlikely to be appropriate.","sssi_statement":"The site is not within 250m of a SSSI","sewer_statement":"The site is further than 100m from a sewer. Discharge to sewer is unlikely to be appropriate.","fluvial_and_coastal_flood_risk_statement":"The site has a negligible risk of fluvial or coastal flooding.","surface_water_flood_risk_statement":"The site has a negligible risk of surface water flooding.","groundwater_flood_risk_statement":"The site has a negligible risk of groundwater flooding.","site_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg","site_location_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SiteLocation.jpg","aerial_photo_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_AerialImage.jpg","suds_infiltration_suitability_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SuD50m.jpg","site_topography_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_DTM5m.jpg","spz_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SPZ.jpg","groundwater_flood_risk_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_GWFloodRisk5m.jpg","rivers_and_seas_flood_risk_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_RoFRS.jpg","surface_water_flood_risk_100yr_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_PluvialDepth100yr.jpg","surface_water_flood_risk_30yr_map_uri":"http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_PluvialDepth30yr.jpg","aerial_photo":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_AerialImage.jpg]","suds_infiltration_suitability_map":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SuD50m.jpg]","site_topography_map":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_DTM5m.jpg]","spz_map":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SPZ.jpg]","groundwater_flood_risk_map":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_GWFloodRisk5m.jpg]","rivers_and_seas_flood_risk_map":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_RoFRS.jpg]","surface_water_features_map":"[imageUrl:http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_WaterFeatures.jpg]"}'
      replacements =
      [
        ['site_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg'],
        ['site_location_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SiteLocation.jpg'],
        ['aerial_photo_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_AerialImage.jpg'],
        ['suds_infiltration_suitability_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SuD50m.jpg'],
        ['site_topography_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_DTM5m.jpg'],
        ['spz_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SPZ.jpg'],
        ['surface_water_features_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_WaterFeatures.jpg'],
        ['rivers_and_seas_flood_risk_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_RoFRS.jpg'],
        ['surface_water_flood_risk_30yr_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_PluvialDepth30yr.jpg'],
        ['groundwater_flood_risk_map_uri', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_GWFloodRisk5m.jpg'],
      ]
      template.write_to_file(json_string, replacements, 'SuDSmart.docx')
    end

  end

end
