class SuspendController < ApplicationController
  skip_before_action :verify_authenticity_token

    def upload
        # Parse form parameters
        subdomain = params[:subdomain]
        domain = params[:domain]
        api_key = params[:api_key]
        csv_file = params[:file].tempfile
    
        # Iterate through CSV rows and suspend users
        CSV.foreach(csv_file) do |row|
          user_id = row[0]
          uri = "https://#{subdomain}.#{domain}/v1/manage/user/#{user_id}/suspend"
          response = HTTParty.post(uri, headers: {"Authorization" => "Bearer #{api_key}"})
          # TODO: Handle API response
        end
    
        flash[:success] = "Users suspended successfully!"  
        redirect_to scripts_dynamic_suspend_users_url
      end
  end