class V1::EventsController < ApplicationController
  before_action :set_event, only: [:show]
  before_action :set_stripe_id, only: [:index, :show]

  def index
    @events = Event.find_all_with_params(event_params)

    render json: @events
  end

  def show
    if @event.blank?
      stripe_response = Stripe::Event.retrieve(event_params[:id])

      @event = Event.build_new!(@stripe_id, stripe_response)
    end

    render json: @event
  end

  private

  def set_stripe_id
    @stripe_id = Rails.application.secrets.stripe_api_key

    Stripe.api_key = @stripe_id
  end

  def set_event
    @event = Event.where(object_id: event_params[:id]).first
  end

  def event_params
    permitted_values = [:id, :ending_before, :limit, :starting_after, :type]

    if params[:created].is_a?(String)
      permitted_values << :created
    else
      permitted_values << [created: [:gt, :gte, :lt, :lte]]
    end

    params.permit(permitted_values).to_h.deep_symbolize_keys
  end
end
