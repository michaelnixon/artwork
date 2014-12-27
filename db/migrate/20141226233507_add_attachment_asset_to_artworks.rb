class AddAttachmentAssetToArtworks < ActiveRecord::Migration
  def self.up
    change_table :artworks do |t|
      t.attachment :asset
    end
  end

  def self.down
    remove_attachment :artworks, :asset
  end
end
