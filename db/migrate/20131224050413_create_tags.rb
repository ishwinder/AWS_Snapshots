class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string  :key
      t.string  :value
      t.references :tagable, polymorphic: true
    end
  end
end
