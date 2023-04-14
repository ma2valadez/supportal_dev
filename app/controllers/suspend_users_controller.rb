require 'httparty'

class SuspendUsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def upload
    # Parse form parameters
    subdomain = params[:subdomain]
    domain = params[:domain]
    api_key = params[:api_key]
    csv_file = params[:file].tempfile
    confirmation = params[:confirmation]

    # Check if the user has confirmed the action
    unless confirmation.downcase == 'confirm'
      flash[:danger] = "Suspending users may have consequences. Type 'confirm' to acknowledge this risk."
      redirect_to scripts_dynamic_suspend_users_url and return
    end
  
    url = "https://#{subdomain}.#{domain}/v1/manage/groups"
    headers = {
      "Authorization": "Bearer #{api_key}",
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  
    # Send first request to check if the API credentials are valid
    response = HTTParty.get(url, headers: headers, verify: true)
  
    if response.success?
      # Iterate through CSV rows and suspend users
      CSV.foreach(csv_file, headers: true) do |row|
        user_id = row[0]
        uri = "https://#{subdomain}.#{domain}/v1/manage/user/#{user_id}/suspend"
  
        begin
          response = HTTParty.post(uri, headers: {"Authorization" => "Bearer #{api_key}"})
          unless response.success?
            flash[:danger] = "Error suspending user #{user_id}: #{response.code} #{response.message}"
          end
        rescue StandardError => e
          flash[:warning] = "Error suspending user #{user_id}: #{e.message}"
        end
      end
  
      flash[:success] = "Users suspended successfully!"
      redirect_to scripts_dynamic_suspend_users_url
    else
      flash[:danger] = "Invalid credentials: #{response.code} #{response.message}"
      redirect_to scripts_dynamic_suspend_users_url
    end
  end
end
