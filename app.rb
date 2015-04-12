require 'sinatra'
require 'sinatra/activerecord'
require 'geocoder'
require 'csv'

set :database, {adapter: 'sqlite3', database: 'database.sqlite3'}
set :heat_radius, 40

get '/' do
  @geopoints = Geopoint.get_heatmap_points
  @radius = settings.heat_radius
  erb :index
end

get '/upload' do
  erb :upload
end

post '/upload' do
  Geopoint.update_from_csv(params['points'][:tempfile].read)
  redirect to('/')
end

class Geopoint < ActiveRecord::Base
  RADIUS = 0.01

  validates_presence_of :lng, :lat, :intensity

  class << self
    def get_heatmap_points
      heatmap = []
      points = Geopoint.pluck(:lng, :lat, :intensity)
      points.each do |point|
        weight = point[2]+1
        weight.times do
          heatmap << Geocoder::Calculations.random_point_near([point[0], point[1]], Geopoint::RADIUS)
        end
      end

      heatmap
    end

    def update_from_csv(source)
      ActiveRecord::Base.transaction do
        Geopoint.delete_all
        CSV.parse(source) do |row|
          Geopoint.create!(lng: row[0], lat: row[1], intensity: row[2])
        end
      end
    end
  end
end
