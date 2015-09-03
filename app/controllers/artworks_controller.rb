require 'zip'
class ArtworksController < ApplicationController
  before_action :set_artwork, only: [:show, :edit, :update, :destroy]

  # GET /artworks
  # GET /artworks.json
  # param :search, String, "A search parameter to refine terms"  
  def index
    @artworks = (Artwork.search(params[:search]) + Artwork.tagged_with(params[:search], :any => true)).uniq
  end

  def index_data_tables
    respond_to do |format|
      format.json { render json: ArtworkDatatable.new(view_context)}
    end    
  end

  # GET /artworks/1
  # GET /artworks/1.json
  def show
  end

  # GET /artworks/new
  def new
    @artwork = Artwork.new
  end

  # GET /artworks/1/edit
  def edit

  end

  # POST /artworks
  # POST /artworks.json
  def create
    @artwork = Artwork.new(artwork_params)
    @artwork.owner = current_user
    respond_to do |format|
      if @artwork.save
        format.html { redirect_to @artwork, notice: 'Artwork was successfully created.' }
        format.json { render :show, status: :created, location: @artwork }
      else
        format.html { render :new }
        format.json { render json: @artwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artworks/1
  # PATCH/PUT /artworks/1.json
  def update
    respond_to do |format|
      if @artwork.update(artwork_params)
        format.html { redirect_to @artwork, notice: 'Artwork was successfully updated.' }
        format.json { render :show, status: :ok, location: @artwork }
      else
        format.html { render :edit }
        format.json { render json: @artwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /artworks/1
  # DELETE /artworks/1.json
  def destroy
    @artwork.destroy
    respond_to do |format|
      format.html { redirect_to artworks_url, notice: 'Artwork was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export
    t = Tempfile.new("temp-artworks-package-#{Time.now}")  
    Zip::OutputStream.open(t.path) do |z|
      #TODO: add license and readme with some meta info
      license = Tempfile.new("license-#{Time.now}")
      preamble = "Thanks for downloading from the artworks database. Here are the licensing terms.\n"
      license.write(preamble)
      z.put_next_entry("license.txt")
      z.print IO.read(open(license))
      params[:includeds].each do |id|
        artwork = Artwork.find(id)
        title = artwork.asset.original_filename
        z.put_next_entry(title)
        url = artwork.asset.path
        url_data = open(url)
        z.print IO.read(url_data)        
      end  
    end

    send_file t.path, :type => 'application/zip',
      :disposition => 'attachment',
      :filename => "artworks.zip"
      t.close
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artwork
      @artwork = Artwork.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def artwork_params
      # params.require(:artwork).permit(:name, :artist_id, :start_date, :completion_date, :dimensions, :gallery_info, :asset, :description, :custom_tags)      
      params.require(:artwork).permit!
    end
    
    def sanitize_filename(filename)
      return filename.strip do |name|
       # NOTE: File.basename doesn't work right with Windows paths on Unix
       # get only the filename, not the whole path
       name.gsub!(/^.*(\\|\/)/, '')

       # Strip out the non-ascii character
       name.gsub!(/[^0-9A-Za-z.\-]/, '_')
      end
    end    
end

 # 
 # group_dir = sanitize_filename("group-#{group.name}")
 #  group.takes.where(public: true).each do |take|
 #    take_dir = sanitize_filename("take-#{take.name}")
 #    take.data_tracks.where(public: true).each do |track|
 #      title = track.asset.file_file_name
 #      temp_filename = sanitize_filename("#{project_dir}/#{group_dir}/#{take_dir}track-#{track.name}/#{title}")
 #      z.put_next_entry(temp_filename)
 #      url = track.asset.file.path
 #      url_data = open(url)
 #      z.print IO.read(url_data)
 #    end
 #  end