require "rails_helper"

RSpec.describe V1::EventsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/v1/events").to route_to("v1/events#index")
    end

    it "routes to #show" do
      expect(:get => "/v1/events/1").to route_to("v1/events#show", :id => "1")
    end

  end
end
