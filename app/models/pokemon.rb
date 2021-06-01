class Pokemon < ApplicationRecord
  CATEGORIES = %w[electric fire water grass flying poison bug normal ground].freeze

  acts_as_taggable_on :tags # or whatever you would like to call your tag list.

  belongs_to :user

  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings

  validates :name, :location, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :description, length: { minimum: 25 }
end
