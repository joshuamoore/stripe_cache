class V1::EventsController < ApplicationController
  before_action :set_event, only: [:show]

  def index
    # created - OPTIONAL - a string with an integer Unix timestamp, or it can be a dictionary with the following options
    # ending_before - OPTIONAL - ending_before is an object ID that defines your place in the list
    # limit - OPTIONAL (default 10) - range between 1 and 100 items
    # starting_after - OPTIONAL - starting_after is an object ID that defines your place in the list
    # type - OPTIONAL - A string containing a specific event name, or group of events using * as a wildcard

    @events = Event.all

    render json: @events
  end

  def show
    # id - REQUIRED - The identifier of the event to be retrieved.

    if @event.blank?
      # make call to stripe api
      stripe_response = Stripe::Event.retrieve(event_params[:id])

      @event = Event.build_new!(event_params[:stripe_id], stripe_response)
    end

    render json: @event
  end

  private

  def set_event
    @event = Event.where(stripe_id: event_params[:stripe_id], object_id: evnet_params[:id]).first
  end

  def event_params
    params.
      permit(
        :stripe_id, :id, :ending_before, :limit, :starting_after, :type,
        created: [:gt, :gte, :lt, :lte]
      )
  end
end
