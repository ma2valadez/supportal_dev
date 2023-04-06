require 'httparty'
require 'csv'

class ProtectedPagesController < ApplicationController
  before_action :logged_in_user

  def show
  end

  def dynamic
  end

  def get_users
    @endpoints = ['Affiliations', 'Channels', 'Images', 'ScheduleSettings', 'idsOnly']
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

    headers = {
      "Authorization": "Bearer #{api_key}",
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
    
    response = HTTParty.get(url, headers: headers, verify: true)

    if response.success?
      # Parse the JSON response into a hash
      parsed_response = JSON.parse(response.body)

      # Open a CSV file for writing and write the header row
      csv_data = CSV.generate do |csv|
        csv << [:id, :display_name, :full_name, :first_name, :last_name, :status, :email, :sso_id]

        # Loop through each user and write a row to the CSV file
        parsed_response['users'].each do |user|
          csv << [user['id'], user['displayName'], user['fullName'], user['firstName'], user['lastName'], user['status'],
                  user['email'], user['externalSsoUserId']]
          end
        end

      # Set the flash message
      flash[:success] = "CSV file generated successfully!"
    
      # Set the Content-Disposition header to force the browser to download the file
      headers['Content-Disposition'] = "attachment; filename=users.csv"

      # Send the CSV data as a file download
      send_data csv_data, type: 'text/csv; charset=utf-8; header=present', filename: 'users.csv', disposition: 'attachment', headers: headers

    else
      flash[:danger] = "There was an error generating the CSV file"
      render :get_users
    end
  end  
end