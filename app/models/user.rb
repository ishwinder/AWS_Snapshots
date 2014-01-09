class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :schedules, dependent: :destroy
  has_many :scheduled_snapshots, dependent: :restrict
  has_many :snapshot_summaries, dependent: :destroy
  has_many :scheduled_summaries, dependent: :destroy

  REGIONS = {"us-east-1" => ["all", "us-east-1a", "us-east-1c", "us-east-1d"], 
             "us-west-2" => ["all", "us-west-2a", "us-west-2b", "us-west-2c"], 
             "us-west-1" => ["all", "us-west-1a", "us-west-1b"], 
             "eu-west-1" => ["all", "eu-west-1a", "eu-west-1b", "eu-west-1c"], 
             "ap-southeast-1" => ["all", "ap-southeast-1a", "ap-southeast-1b"], 
             "ap-southeast-2" => ["all", "ap-southeast-2a", "ap-southeast-2b"], 
             "ap-northeast-1"=> ["all", "ap-northeast-1a", "ap-northeast-1c"], 
             "sa-east-1" => ["all", "sa-east-1a", "sa-east-1b"]}
end
