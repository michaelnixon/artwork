class CreateArtworks < ActiveRecord::Migration
  def change
    create_table :artworks do |t|
      t.string :name
      t.date :start_date
      t.date :completion_date
      t.string :dimensions
      t.string :gallery_info

      t.timestamps
    end
  end
end
