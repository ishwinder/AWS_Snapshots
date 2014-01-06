class Schedule < ActiveRecord::Base
  belongs_to :user
  has_many :events, dependent: :destroy

  serialize :instances, Array

  accepts_nested_attributes_for :events, reject_if: proc { |attributes| attributes['key'].blank? || attributes['value'].blank?}
end
