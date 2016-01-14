require 'rails_helper'
require 'stripe_mock'

RSpec.describe Event, type: :model do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before { StripeMock.start }
  after { StripeMock.stop }

  it { should validate_presence_of(:object_id) }
  it { should validate_presence_of(:data) }

  describe "#self.build_new!" do
    before :each do
      @stripe_id = Stripe.api_key
      @webhook = StripeMock.mock_webhook_event("customer.created")
      @events = Stripe::Event.all
      @event_from_stripe = @events.data.first
    end

    it "should have error for missing stripe_id" do
      Event.build_new!(nil, @event_from_stripe).should have(1).error_on(:stripe_id)
    end

    it "should have error for missing id" do
      Event.build_new!(@stripe_id, nil).should have(1).error_on(:object_id)
    end

    it "should have error for missing data" do
      Event.build_new!(@stripe_id, nil).should have(1).error_on(:data)
    end

    it "should fetch and save event"
    it "should return event from database"
  end

  describe "#self.find_all_with_params" do
    before :each do
      @webhook_1 = StripeMock.mock_webhook_event("customer.created")
      @webhook_2 = StripeMock.mock_webhook_event("customer.created")
      @webhook_3 = StripeMock.mock_webhook_event("customer.created")
    end

    it "should fetch and save events from the api"
    it "should recurse over pagination keys and save events"
    it "should return cached version"
    it "should re-sync data if it's out of sync with the API"
  end

  describe "#self.conditions_for_stripe" do
    before :each do
      @timestamp = Time.zone.now.to_i
      @object_id = "evt_17RVUT2eZvKYlo2CPhMqRYPT"
    end

    it "should return empty hash if params are empty" do
      Event.conditions_for_stripe.should be {}
    end

    it "should build created as timestamp" do
      params = { created: @timestamp }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should build created gt as timestamp" do
      params = { created: { gt: @timestamp } }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should build created gte as timestamp" do
      params = { created: { gte: @timestamp } }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should build created lt as timestamp" do
      params = { created: { lt: @timestamp } }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should build created lte as timestamp" do
      params = { created: { lte: @timestamp } }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should ignore ending_before if value is not a valid event" do
      params = { ending_before: 12345 }

      Event.conditions_for_stripe(params).should eq({})
    end

    it "should build ending_before value is a valid event" do
      params = { ending_before: @object_id }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should ignore limit if value is < 1" do
      params = { limit: 0 }

      Event.conditions_for_stripe(params).should eq({})
    end

    it "should ignore limit if value is > 100" do
      params = { limit: 101 }

      Event.conditions_for_stripe(params).should eq({})
    end

    it "should build limit" do
      params = { limit: 50 }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should ignore starting_after if value is not a valid event" do
      params = { ending_before: 12345 }

      Event.conditions_for_stripe(params).should eq({})
    end

    it "should build starting_after value is a valid event" do
      params = { starting_after: @object_id }

      Event.conditions_for_stripe(params).should eq(params)
    end

    it "should ignore type if value is not present" do
      params = { type: nil }

      Event.conditions_for_stripe(params).should eq({})
    end

    it "should build type" do
      params = { type: "charge.succeeded" }

      Event.conditions_for_stripe(params).should eq(params)
    end
  end

  describe "#self.conditions_for_params" do
    before :each do
      @timestamp = Time.zone.now.to_i
    end

    it "should return empty hash if params are empty" do
      Event.conditions_for_params.should eq(["", {}])
    end

    it "should build created as timestamp" do
      params = { created: @timestamp }

      Event.conditions_for_params(params).should eq(["(data ->> 'created')::int = :created", params])
    end

    it "should build created gt as timestamp" do
      params = { created: { gt: @timestamp } }

      Event.conditions_for_params(params).should eq(["(data ->> 'created')::int > :created", { created: @timestamp }])
    end

    it "should build created gte as timestamp" do
      params = { created: { gte: @timestamp } }

      Event.conditions_for_params(params).should eq(["(data ->> 'created')::int >= :created", { created: @timestamp }])
    end

    it "should build created lt as timestamp" do
      params = { created: { lt: @timestamp } }

      Event.conditions_for_params(params).should eq(["(data ->> 'created')::int < :created", { created: @timestamp }])
    end

    it "should build created lte as timestamp" do
      params = { created: { lte: @timestamp } }

      Event.conditions_for_params(params).should eq(["(data ->> 'created')::int <= :created", { created: @timestamp }])
    end

    it "should build type" do
      params = { type: "charge.succeeded" }

      Event.conditions_for_params(params).should eq(["data ->> 'type' = :type", params])
    end
  end

  describe "#self.is_valid_event?" do
    it "should be false" do
      Event.is_valid_event?("12345").should be false
    end

    it "should be true" do
      # method should test based on production values. testing suite returns 'test_' prefix
      Event.is_valid_event?("evt_17RVUT2eZvKYlo2CPhMqRYPT").should be true
    end
  end
end

