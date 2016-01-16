class ChangeStripeIdType < ActiveRecord::Migration[5.0]
  def change
    change_column :events, :stripe_id, :string
  end
end
