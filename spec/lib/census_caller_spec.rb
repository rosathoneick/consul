require 'rails_helper'

describe CensusCaller do
  let(:api) { described_class.new }

  describe '#call' do
    it "returns data from local_census_records if census API is not available" do
      Setting['feature.local_census'] = true
      Setting['feature.census_api'] = false

      census_api_response = CensusApi::Response.new({})
      local_census_response = LocalCensus::Response.new(create(:local_census_record))

      CensusApi.any_instance.stub(:call).and_return(census_api_response)
      LocalCensus.any_instance.stub(:call).and_return(local_census_response)

      allow(CensusApi).to receive(:call).with(1, "12345678A")
      allow(LocalCensus).to receive(:call).with(1, "12345678A")

      response = api.call(1, "12345678A")

      expect(response).to eq(local_census_response)
    end

    it "returns data from census API if it's available and valid" do
      Setting['feature.local_census'] = false
      Setting['feature.census_api'] = true

      census_api_response = CensusApi::Response.new({date_of_birth: "1-1-1980"})
      local_census_response = LocalCensus::Response.new(create(:local_census_record))

      CensusApi.any_instance.stub(:call).and_return(census_api_response)
      LocalCensus.any_instance.stub(:call).and_return(local_census_response)

      allow(CensusApi).to receive(:call).with(1, "12345678A")
      allow(LocalCensus).to receive(:call).with(1, "12345678A")

      response = api.call(1, "12345678A")

      expect(response).to eq(census_api_response)
    end
  end

end
