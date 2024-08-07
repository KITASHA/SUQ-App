class GigsController < ApplicationController
  before_action :basic_auth
  #, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_gig, only: [:show, :edit, :update, :destroy]
  before_action :load_bands, only: [:new, :edit]

  def index
    @gigs = Gig.includes(:bands).order(date: :asc)
  end

  def new
    @gig = Gig.new
  end

  def create
    @gig = Gig.new(gig_params)
    @gig.user_id = current_user.id 

    if @gig.save
      redirect_to @gig
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @gig.update(gig_params)
      redirect_to @gig
    else
      render :edit
    end
  end

  def destroy
    @gig.destroy
    redirect_to gigs_path
  end

  private
  def find_gig
    @gig = Gig.find(params[:id])
  end

  def gig_params
    params.require(:gig).permit(:gig_name, :date, :start_time, :end_time, :description, :link_name, :link_url, :image, band_ids: [])
  end

  def load_bands
    @bands = Band.all
  end

  
  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER_SQUARE'] && password == ENV['BASIC_AUTH_PASSWORD_SQUARE']
    end
  end
  
  
end