class Event < ApplicationRecord

  validates_presence_of :stripe_id, :object_id, :data

  def self.build_new!(stripe_id, stripe_response)
    Event.create(stripe_id: stripe_id, object_id: stripe_response.try(:id), data: stripe_response.as_json)
  end

  def self.find_all_with_params(params={})
    conditions = Event.conditions_for_stripe(params)

    conditions["include[]"] = "total_count"

    response = Stripe::Event.all(conditions)
    response_data = response.data

    has_more = response.has_more
    total_count = response.total_count
    local_count = Event.records_for_params(params).count
    has_synced_results = local_count >= total_count
    if !has_synced_results
      # query number of events that match the params in our database
      # and if the number in stripe is different than the number in the db
      # then delete all in the db and save all and recurse the stripe data
      if total_count != local_count
        response_data.each do |stripe_response|
          Event.build_new!(Rails.application.secrets.stripe_api_key, stripe_response)
        end
      end

      # if there are more events to be had, then paginate via recursion
      if has_more
        starting_after = response_data.last.id

        params[:starting_after] = starting_after
        puts "paginating.... #{starting_after}"

        Event.find_all_with_params(params)
      end
    end
  end

  def self.conditions_for_stripe(params={})
    conditions = {}

    if params[:created].is_a?(Integer)
      conditions[:created] = params[:created]
    elsif params[:created].is_a?(Hash)
      conditions[:created] = {}

      if params[:created][:gt].is_a?(Integer)
        conditions[:created][:gt] = params[:created][:gt]
      elsif params[:created][:gte].is_a?(Integer)
        conditions[:created][:gte] = params[:created][:gte]
      elsif params[:created][:lt].is_a?(Integer)
        conditions[:created][:lt] = params[:created][:lt]
      elsif params[:created][:lte].is_a?(Integer)
        conditions[:created][:lte] = params[:created][:lte]
      end
    end

    if params[:ending_before].present? && Event.is_valid_event?(params[:ending_before])
      conditions[:ending_before] = params[:ending_before]
    end

    if params[:limit].present? && (params[:limit].to_i > 1 && params[:limit].to_i <= 100)
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

    conditions
  end

  def self.conditions_for_params(params={})
    conditions = []
    values = {}

    if params[:created].is_a?(Integer)
      conditions << "(data ->> 'created')::int = :created"
      values[:created] = params[:created]
    elsif params[:created].is_a?(Hash)
      if params[:created][:gt].is_a?(Integer)
        conditions << "(data ->> 'created')::int > :created"
        values[:created] = params[:created][:gt]
      elsif params[:created][:gte].is_a?(Integer)
        conditions << "(data ->> 'created')::int >= :created"
        values[:created] = params[:created][:gte]
      elsif params[:created][:lt].is_a?(Integer)
        conditions << "(data ->> 'created')::int < :created"
        values[:created] = params[:created][:lt]
      elsif params[:created][:lte].is_a?(Integer)
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

    [conditions.join(" AND "), values]
  end

  def self.records_for_params(params={})
    Event.where(Event.records_for_params(params))
  end

  def self.is_valid_event?(value)
    value.to_s.start_with?("evt_")
  end
end
