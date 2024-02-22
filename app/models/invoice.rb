class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_items
  has_many :transactions
  
  validates :status, presence: true, numericality: true
  
  enum status: {"in progress" => 0, "completed" => 1, "canceled" => 2}
end