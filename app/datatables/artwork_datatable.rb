class ArtworkDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::Kaminari
  def_delegators :@view, :link_to, :truncate, :artist_path, :artwork_path

  def initialize(view)
    @view = view
  end

  def sortable_columns
    # dynamic_columns = Artwork.tag_context_list.map {|tag| "Artwork.tag_list_content_on('#{tag}')"}   
    # sorting may not work since the tag relationship includes all of them and then they're put into an order even though they're spread between columns
    dynamic_columns = Artwork.tag_context_list.map {|tag| 'ActsAsTaggableOn::Tag.name'}   
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Artwork.name', 'Artwork.description', 'Artwork.start_date', 'Artwork.completion_date', 'Artwork.dimensions', 
      'Artwork.gallery_info', 'Artist.name', dynamic_columns].flatten
  end

  def searchable_columns
    # dynamic_columns = [] #Artwork.tag_context_list.map {|tag| 'ActsAsTaggableOn::Tagging.tag.name'}     # these are the actual searchable columns
    # Declare strings in this format: ModelName.column_name
    dynamic_columns = Artwork.tag_context_list.map {|tag| 'ActsAsTaggableOn::Tag.name'}   
    @searchable_columns ||= ['Artwork.name', 'Artwork.description', 'Artwork.start_date', 'Artwork.completion_date', 'Artwork.dimensions', 
      'Artwork.gallery_info', 'Artist.name', dynamic_columns].flatten
    # @searchable_columns = @searchable_columns + dynamic_columns
  end

  private

  def data
        #a.tag_context_list.map {|tag| "Artwork.tag_list_content_on(#{tag})"} ##{tag}_list
    records.map do |record|
      dynamic_columns = Artwork.tag_context_list.map {|tag| record.tag_list_content_on(tag)}      
      [
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
        link_to(truncate(record.name, length: 40), artwork_path(record)), 
        truncate(record.description, length: 60), 
        record.start_date, 
        record.completion_date, 
        record.dimensions,
        record.gallery_info,
        link_to(record.artist.try(:name), artist_path(record.artist)), 
        dynamic_columns
          # record.sensor_types.map{|type| link_to(type.name, sensor_type_path(type)) }.join(", "), 
          # record.movers.map{|mover| link_to(mover.name, mover_path(mover)) }.join(", "),
          # record.technician, record.recorded_on, record.tag_list        
      ].flatten
    end
  end

  def get_raw_records
    # insert query here
    # update later to include filtering
#    @artworks = Artwork.includes(:artist, :taggings, :tags).references(:artist, :taggings, :tags).distinct #.explain
    @artworks = Artwork.includes(:artist, :base_tags).references(:artist, :base_tags)
    # if @current_user
    #   @data_tracks.select! { |data_track| data_track.public? or data_track.is_accessible_by?(@current_user)  }
    # else
    #   @data_tracks.select! { |data_track| data_track.public? }
    # end    
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
