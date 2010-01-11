class CreateTables < Sequel::Migration
  def tables
    [:page, :posts]
  end

  def up
    tables.each do |table|
      create_table table do
        primary_key :path, :string, :size => 255, :auto_increcement => false
        text :content
      end
    end
  end

  def down
    tables.reverse!.each { |table| drop_table table }
  end
end
