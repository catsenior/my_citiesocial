class Vendor < ApplicationRecord
  validates :title,presence: true

  scope :available, -> { where(online: true)}
end
