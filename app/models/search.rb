class Search < ActiveRecord::Base
  attr_accessor :name, :description, :dimensions, :artist_id, :gallery_info, :tag_ids, :start_date, :completion_date
   # validates_presence_of :keywords
   
   def artworks
     @artworks ||= find_artworks
   end
   
   private

   def find_artworks
     # Artwork.find(:all, :conditions => conditions)
     ids = tag_ids.reject(&:empty?)
     if ids.blank?
       artworks = Artwork.includes(:artist).where(conditions)
     else
       tags = ActsAsTaggableOn::Tag.find(ids) unless ids.blank?     
       artworks = Artwork.includes(:artist).where(conditions).tagged_with tags
     end
   end

   def name_conditions
     ["artworks.name LIKE ?", "%#{name}%"] unless name.blank?
   end

   def description_conditions
     ["artworks.description LIKE ?", "%#{description}%"] unless description.blank?
   end
   
   def dimensions_conditions
     ["artworks.dimensions LIKE ?", "%#{dimensions}%"] unless dimensions.blank?
   end
      
   def gallery_info_conditions
     ["artworks.gallery_info LIKE ?", "%#{gallery_info}%"] unless gallery_info.blank?
   end
   
   def start_date_conditions
     ["artworks.start_date LIKE ?", "%#{start_date}%"] unless start_date.blank?
   end
   
   def completion_date_conditions
     ["artworks.completion_date LIKE ?", "%#{completion_date}%"] unless completion_date.blank?
   end      

   def artist_conditions
     ["artworks.artist_id = ?", artist_id] unless artist_id.blank?
   end
   
   def conditions
     [conditions_clauses.join(' AND '), *conditions_options]
   end

   def conditions_clauses
     conditions_parts.map { |condition| condition.first }
   end

   def conditions_options
     conditions_parts.map { |condition| condition[1..-1] }.flatten
   end

   def conditions_parts
     private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
   end
   
   # just here as examples of how to do different types of searches
   def minimum_price_conditions_foo
     ["artworks.price >= ?", minimum_price] unless minimum_price.blank?
   end

   def maximum_price_conditions_foo
     ["artworks.price <= ?", maximum_price] unless maximum_price.blank?
   end   
end
