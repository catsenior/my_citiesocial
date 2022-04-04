class Vendor < ApplicationRecord
  validates :title,presence: true
  acts_as_paranoid
  scope :available, -> { where(online: true)}
end
