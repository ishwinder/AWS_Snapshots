class Instance < ActiveRecord::Base
  belongs_to :schedule
  validates :instance, uniqueness: {scope: :schedule_id}
end
