module DeleteSnapshot
  @queue = :droping_snapshots
  def self.perform
    snapshots = SnapshotSummary.where(auto_delete_on: Date.today)
    if !snapshots.empty?
      snapshots.each do |snapshot|
        ec2 = AWS::EC2.new(access_key_id: snapshot.user.access_key, secret_access_key: snapshot.user.secret_token)
        ec2.client.delete_snapshot({snapshot_id: snapshot.snapshot_id})
      end
    end
  end
end