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
  
    url = "https://#{subdomain}.#{domain}/v1/manage/groups/#{id}/users"
    url += "?include=#{includes}" if includes.present?
    
    response = HTTParty.get(url, headers: { "Authorization" => "Bearer #{api_key}" }, verify: false)

    if response.success?
      csv_data = CSV.generate do |csv|
        csv << response["users"].first.keys
          response["users"].each do |user|
            csv << user.values
        end
      end

      # send_data csv_data, 
      #           type: 'text/csv',
      #           disposition: "attachment; filename=users.csv"
      flash[:success] = "CSV file generated successfully!"

      # Save the CSV data to a session variable
      session[:csv_data] = csv_data
      redirect_to download_users_path
    else
      flash[:error] = "There was an error generating the CSV file"
      redirect_to :back
    end
  rescue StandardError => e
    flash[:error] = "There was an error downloading user data: #{e.message}"
    redirect_to :back
  end
end

def download_file
  # Retrieve the CSV data from the session variable
  csv_data = session[:csv_data]

  # Create a link to download the CSV file
  send_data csv_data, filename: 'users.csv', type: 'text/csv', disposition: 'attachment'
end
  

