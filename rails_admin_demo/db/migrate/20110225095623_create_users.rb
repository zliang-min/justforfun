class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :null => false, :limit => 50
      t.date :birthday

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
