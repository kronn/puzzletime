# == Schema Information
#
# Table name: invoices
#
#  id                 :integer          not null, primary key
#  order_id           :integer          not null
#  billing_date       :date             not null
#  due_date           :date             not null
#  total_amount       :decimal(12, 2)   not null
#  total_hours        :float            not null
#  reference          :string           not null
#  period_from        :date             not null
#  period_to          :date             not null
#  status             :string           not null
#  add_vat            :boolean          default(TRUE), not null
#  billing_address_id :integer          not null
#  invoicing_key      :string
#  created_at         :datetime
#  updated_at         :datetime
#  grouping           :integer          default(0), not null
#

Fabricator(:invoice) do
  order
  billing_address { |attrs| Fabricate(:billing_address, client: attrs[:order].client) }
  work_items(count: 2)
  employees(count: 2)
  billing_date { Date.today }
  period_from { (Date.today - 1.month).at_beginning_of_month }
  period_to { (Date.today - 1.month).at_end_of_month }
end
