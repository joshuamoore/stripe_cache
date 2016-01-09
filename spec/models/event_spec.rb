require 'rails_helper'
require 'stripe_mock'

RSpec.describe Event, type: :model do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  it "creates a stripe customer" do

    # This doesn't touch stripe's servers nor the internet!
    # Specify :source in place of :card (with same value) to return customer with source data
    customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      card: stripe_helper.generate_card_token
    })
    expect(customer.email).to eq('johnny@appleseed.com')
  end
end

