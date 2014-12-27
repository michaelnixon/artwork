class Artwork < ActiveRecord::Base
  belongs_to :artist
  belongs_to :owner, class_name: "User", foreign_key: "user_id"  
  has_attached_file :asset, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :asset, :content_type => /\Aimage\/.*\Z/
end
