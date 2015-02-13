class ChangeDateFormatInArtwork < ActiveRecord::Migration
  def change
    change_column :artworks, :completion_date, :string
    change_column :artworks, :start_date, :string    
  end
end
