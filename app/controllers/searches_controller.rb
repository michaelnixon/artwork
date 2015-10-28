class SearchesController < ApplicationController
  before_action :set_search, only: [:show, :edit, :update, :destroy]
  
  def new
    @search = Search.new
  end
  
  def show
    @search = Search.find(params[:id])
    @artworks = @search.artworks
  end
  
  def create
    @search = Search.new(search_params)
    if @search.save
      @artworks = @search.artworks
      render action: "show", notice: "search was created"
    else
      render action: 'new', notice: "search was not created"
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    def search_params
      # params.require(:artwork).permit(:name, :artist_id, :start_date, :completion_date, :dimensions, :gallery_info, :asset, :description, :custom_tags)      
      params.require(:search).permit!
    end
  
end
