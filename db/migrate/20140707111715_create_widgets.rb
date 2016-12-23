class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :drivers, id: false do |t|
      t.jsonb :data, null: false, default: '{}'
    end
    create_table :metrics, id: false do |t|
      t.jsonb :data, null: false, default: '{}'
    end
  end
end
