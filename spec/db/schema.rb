ActiveRecord::Schema.define do
  create_table 'audit_records', force: true do |t|
    t.integer  'customer_id'
    t.integer  'model_id'
    t.integer  'model_type_id'
    t.string 'action', limit: 6
    t.text     'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'widgets', force: true do |t|
    t.integer  'customer_id'
    t.text     'identifier'
    t.text     'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end
