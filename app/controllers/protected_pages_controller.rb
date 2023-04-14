require 'httparty'
require 'csv'

class ProtectedPagesController < ApplicationController
  before_action :logged_in_user

  def show
  end

  def dynamic
  end

  def get_users
    # @endpoints = ['Affiliations', 'Channels', 'Images', 'ScheduleSettings', 'idsOnly']
  end

  def get_firstup_users
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

      # Check if the parsed response contains 'users'
      if parsed_response.key?('users')

        # Open a CSV file for writing and write the header row
        csv_data = CSV.generate do |csv|
          csv << [:id, :display_name, :full_name, :first_name, :last_name, :status, :email, :sso_id]

        # Loop through each user and write a row to the CSV file
        parsed_response['users'].each do |user|
          csv << [user['id'], user['displayName'], user['fullName'], user['firstName'], user['lastName'], user['status'],
                  user['email'], user['externalSsoUserId']]
          end
        end

        session[:csv_data] = csv_data
        session[:id] = id
        flash[:success] = "CSV file generated successfully!"
        redirect_to download_complete_path

      else
        flash[:danger] = "The response was successful, but did not contain any users. Are you using the correct Group ID?"
        redirect_to scripts_dynamic_get_users_url
      end
    else
      flash[:danger] = "There was an error generating the CSV file"
      redirect_to scripts_dynamic_get_users_url
    end
  end

  def firstup_download_users
    # Get client_id and client_secret from the form data
    client_id = params[:client_id]
    client_secret = params[:client_secret]
  
    # Make a request to the token endpoint to get an access token
    token_response = HTTParty.post('https://auth.socialchorus.com/oauth/token',
      body: {
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret
      })
  
    # Check if the access token was generated successfully
    if token_response.code == 200
      # Parse the response to get the access token
      access_token = token_response.parsed_response['access_token']
      program_id = token_response.parsed_response['realm']
  
      # Make a request to the user data endpoint with the access token
      user_response = HTTParty.get('https://partner.socialchorus.com/scim/v2/Users',
        headers: {
          'Authorization' => "Bearer #{access_token}"
        },
        format: :json # Add this line to indicate that the response should be in JSON format
      )
  
      # Check if the user data was fetched successfully
      if user_response.code == 200
        # Parse the user data and save it to CSV
        users = user_response.parsed_response['Resources']
        csv_data = CSV.generate do |csv|
          csv << ['Associate ID', 'User Name', 'External ID', 'Email', 'Roles', 'First Name', 'Last Name', 'Display Name']
          users.each do |user|
            # Check if the required fields are present
            if user.key?('id') && user.key?('userName') && user.key?('name') && user['name'].key?('givenName') && user['name'].key?('familyName') && user.key?('displayName')
              # Get the values of the fields
              id = user['id']
              user_name = user['userName']
              external_id = user['externalId'] || ''
              email = user['emails'][0]['value'] if user['emails'].present?
              role = user['roles'][0]['value'] if user['roles'].present?
              given_name = user['name']['givenName']
              family_name = user['name']['familyName']
              display_name = user['displayName']
      
              # Add the values to the CSV row
              csv << [id, user_name, external_id, email, role, given_name, family_name, display_name]
            end
          end
        end
  
        # Send the CSV as a file download
        session[:csv_data] = csv_data
        session[:program_id] = program_id
        flash[:success] = "CSV file generated successfully!"
        redirect_to firstup_download_complete_path
      else
        # Render an error message
        flash[:danger] = "Error fetching user data: #{user_response.code} #{user_response.message}"
        redirect_to scripts_firstup_get_users_url
      end
    else
      # Render an error message
      flash[:danger] = "Error generating access token: #{token_response.code} #{token_response.message}"
      redirect_to scripts_firstup_get_users_url
    end
  end
  
  def download_complete

    # Delete session data from download users method
    csv_data = session.delete(:csv_data)
    id = session.delete(:id)

    # Set the filename based on the id and today's date
    filename = "group_#{id}_users_#{Date.today.strftime('%Y-%m-%d')}.csv"

    # Set the Content-Disposition header to force the browser to download the file
    headers['Content-Disposition'] = "attachment; filename=#{filename}"

    # Send the CSV data as a file download
    send_data csv_data, type: 'text/csv; charset=utf-8; header=present', filename: filename, disposition: 'attachment', headers: headers
  end

  def firstup_download_complete

    # Delete session data from download users method
    csv_data = session.delete(:csv_data)
    program_id = session.delete(:program_id)

    # Set the filename based on the id and today's date
    filename = "#{program_id}_users_#{Date.today.strftime('%Y-%m-%d')}.csv"

    # Set the Content-Disposition header to force the browser to download the file
    headers['Content-Disposition'] = "attachment; filename=#{filename}"

    # Send the CSV data as a file download
    send_data csv_data, type: 'text/csv; charset=utf-8; header=present', filename: filename, disposition: 'attachment', headers: headers
  end
end