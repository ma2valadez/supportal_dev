require 'csv'
require 'net/http'

class ProtectedPagesController < ApplicationController
  before_action :logged_in_user

  def show
  end

  def dynamic
  end

  def get_users
    @endpoints = ['Affiliations', 'Channels', 'Images', 'ScheduleSettings']
    flash.alert = params[:alert] if params[:alert]
    flash.notice = params[:notice] if params[:notice]
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
    uri = URI(url)
  
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
  
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
  
    response = http.request(request)
  
    if response.code.to_i == 200
      data = JSON.parse(response.body)
      csv_data = CSV.generate(headers: true) do |csv|
        csv << data.first.keys
        data.each do |row|
          csv << row.values
        end
      end
      send_data csv_data, filename: "users.csv"
      flash[:notice] = "CSV file generated successfully!"
      redirect_to action: "get_users", notice: "CSV file generated successfully!"
    else
      flash[:alert] = "There was an error generating the CSV file"
      redirect_to action: "get_users", alert: "There was an error generating the CSV file"
    end
  end
end
  

