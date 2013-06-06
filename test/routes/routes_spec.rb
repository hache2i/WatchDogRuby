require_relative '../../web/app'

require 'rack/test'
require 'rspec'

describe "Notes2Reveal Routes" do
  include Rack::Test::Methods

  before do
  	@app ||= Web.new!
  end

  def app
  	@app
  end

  describe "/generate" do

    it "goes to / when empty json" do
      post "/generate", "json_field" => ""
      last_response.should be_redirect
      follow_redirect!
      last_request.path_info.should == '/'
      last_request.query_string.should == 'alert_signal=empty.json'
    end

    it "goes to / when empty json collection" do
      post "/generate", "json_field" => "[]"
      last_response.should be_redirect
      follow_redirect!
      last_request.path_info.should == '/'
      last_request.query_string.should == 'alert_signal=empty.json.collection'
    end
  end

end