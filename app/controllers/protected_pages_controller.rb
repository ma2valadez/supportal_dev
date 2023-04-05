require 'csv'
require 'httparty'

class ProtectedPagesController < ApplicationController
  before_action :logged_in_user

  def show
  end

  def dynamic
  end

  def get_users
    @endpoints = ['Affiliations', 'Channels', 'Images', 'ScheduleSettings']
  end

  def download_users
    domain = params[:domain]
    subdomain = params[:subdomain]
    api_key = params[:api_key]
    id = params[:id]
    endpoint = params[:endpoint]
    includes = params[:include].join(",") if params[:include]

    if params[:idsOnly] == "true"
      includes = ["idsOnly"]
    else
      includes = []
      includes << "Affiliations" if params[:Affiliations] == "true"
      includes << "Channels" if params[:Channels] == "true"
      includes << "Images" if params[:Images] == "true"
      includes << "ScheduleSettings" if params[:ScheduleSettings] == "true"
      includes = includes.join(",") if includes.present?
    end
  
    url = "https://#{subdomain}.#{domain}.com/v1/manage/groups/#{id}/users"
    url += "?include=#{includes}" if includes.present?
    
    response = HTTParty.get(url, headers: { "Authorization" => "Bearer #{api_key}" }, verify: false)

    if response.success?
      csv_data = CSV.generate do |csv|
        JSON.parse(response.body).each do |record|
          csv << record.values
        end
      end
      send_data csv_data, filename: "users.csv", type: " text/csv", disposition: "attachment"
      flash[:notice] = "CSV file generated successfully!"
      redirect_to action: "get_users", notice: "CSV file generated successfully!"
    else
      flash[:error] = "There was an error generating the CSV file"
      redirect_to action: "get_users", notice: "CSV error"
    end
  end
end
  

