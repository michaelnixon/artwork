class AddArtistRefToArtworks < ActiveRecord::Migration
  def change
    add_reference :artworks, :artist, index: true
  end
end
