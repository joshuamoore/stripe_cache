class Event < ApplicationRecord

  validates_presence_of :stripe_id, :object_id, :data

  LIMIT_MIN = 1
  LIMIT_MAX = 100

  def self.build_new!(stripe_id, stripe_response)
    Event.
      where(stripe_id: stripe_id, object_id: stripe_response.try(:id)).
      first_or_create(data: stripe_response.as_json)
  end

  def self.find_all_with_params(params={})
    conditions = Event.conditions_for_stripe(params)
    response = Stripe::Event.all(conditions)

    response_data = response.data
    has_more = response.has_more
    total_count = response.try(:total_count) || response.data.count
    local_count = Event.records_for_params(params).count

    should_save_events_from_stripe = local_count < total_count

    if should_save_events_from_stripe
      if response_data && response_data.is_a?(Array)
        response_data.each do |stripe_response|
          Event.build_new!(Rails.application.secrets.stripe_api_key, stripe_response)
        end
      end

      # if there are more events to be had, then paginate via recursion
      if has_more && response_data.count > 1
        starting_after = response_data.last.try(:id)

        if starting_after.present?
          params[:starting_after] = starting_after

          Event.find_all_with_params(params)
        end
      else
        Event.records_for_params(params)
      end
    else
      Event.records_for_params(params)
    end
  end

  def self.conditions_for_stripe(params={})
    conditions = {}

    if params[:created].is_a?(String)
      conditions[:created] = params[:created]
    elsif params[:created].is_a?(Hash)
      conditions[:created] = {}

      if params[:created][:gt].is_a?(String)
        conditions[:created][:gt] = params[:created][:gt]
      elsif params[:created][:gte].is_a?(String)
        conditions[:created][:gte] = params[:created][:gte]
      elsif params[:created][:lt].is_a?(String)
        conditions[:created][:lt] = params[:created][:lt]
      elsif params[:created][:lte].is_a?(String)
        conditions[:created][:lte] = params[:created][:lte]
      end
    end

    if params[:ending_before].present? && Event.is_valid_event?(params[:ending_before])
      conditions[:ending_before] = params[:ending_before]
    end

    if params[:limit].present? && (params[:limit].to_i > LIMIT_MIN && params[:limit].to_i <= LIMIT_MAX)
      conditions[:limit] = params[:limit].to_i
    end

    if params[:starting_after].present? && Event.is_valid_event?(params[:starting_after])
      conditions[:starting_after] = params[:starting_after]
    end

    if params[:type].present?
      # "We may add more at any time, so you shouldn't rely on
      # only these types existing in your code."
      conditions[:type] = params[:type]
    end

    # have Stripe include the total number of overall events available
    conditions["include[]"] = "total_count"

    conditions
  end

  def self.conditions_for_params(params={})
    conditions = []
    values = {}
    result = []

    if params[:created].is_a?(String)
      conditions << "(data ->> 'created')::int = :created"
      values[:created] = params[:created]
    elsif params[:created].is_a?(Hash)
      if params[:created][:gt].is_a?(String)
        conditions << "(data ->> 'created')::int > :created"
        values[:created] = params[:created][:gt]
      elsif params[:created][:gte].is_a?(String)
        conditions << "(data ->> 'created')::int >= :created"
        values[:created] = params[:created][:gte]
      elsif params[:created][:lt].is_a?(String)
        conditions << "(data ->> 'created')::int < :created"
        values[:created] = params[:created][:lt]
      elsif params[:created][:lte].is_a?(String)
        conditions << "(data ->> 'created')::int <= :created"
        values[:created] = params[:created][:lte]
      end
    end

    if params[:type].present?
      # "We may add more at any time, so you shouldn't rely on
      # only these types existing in your code."
      conditions << "data ->> 'type' = :type"
      values[:type] = params[:type]
    end

    if conditions.present? && values.present?
      result = [conditions.join(" AND "), values]
    end

    result
  end

  def self.records_for_params(params={})
    Event.where(Event.conditions_for_params(params))
  end

  def self.is_valid_event?(value)
    value.to_s.start_with?("evt_")
  end
end
