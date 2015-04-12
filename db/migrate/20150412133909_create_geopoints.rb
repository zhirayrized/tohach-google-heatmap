class CreateGeopoints < ActiveRecord::Migration
  def change
    create_table :geopoints do |t|
      t.float :lng
      t.float :lat
      t.integer :intensity
    end
  end
end
