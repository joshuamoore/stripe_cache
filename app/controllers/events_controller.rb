class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  def index
    @events = Event.all

    render json: @events
  end

  def show
    render json: @event
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:stripe_id, :data)
  end
end
