require 'httparty'

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
    
    response = HTTParty.get(url, headers: { "Authorization" => "Bearer #{api_key}" }, verify: false)

    if response.success?
      # Parse the JSON response into a hash
      parsed_response = JSON.parse(response.body)

      # Open a CSV file for writing and write the header row
      CSV.open('users.csv', 'wb') do |csv|
        csv << [:id, :display_name, :full_name, :first_name, :last_name, :status, :email, :sso_id]

        # Loop through each user and write a row to the CSV file
        parsed_response['users'].each do |user|
          csv << [user['id'], user['displayName'], user['fullName'], user['firstName'], user['lastName'], user['status'],
                  user['email'], user['externalSsoUserId']]
        end
      end

      flash[:success] = "CSV file generated successfully!"
      send_data csv_data, filename: "users.csv", type: "text/csv", disposition: "attachment", :layout => false
      return
    else
      flash[:danger] = "There was an error generating the CSV file"
      redirect_to scripts_dynamic_get_users_url
    end
  # rescue StandardError => e
  #   flash[:error] = "There was an error downloading user data: #{e.message}"
  #   redirect_to scripts_dynamic_get_users_url
  # end
end


  

