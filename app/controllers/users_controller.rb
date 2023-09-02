class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      notify_third_party_endpoints(@user)
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      notify_third_party_endpoints(@user)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def show
    @user = User.find(params[:id])
    render 'show'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def notify_third_party_endpoints(user)
    third_party_endpoints = [
      'https://example.com/webhook/endpoint1',
      'https://example.com/webhook/endpoint2'
    ]

    third_party_endpoints.each do |endpoint|
      response = send_notification(user, endpoint)
    end
  end

  def send_notification(user, endpoint)
    response = HTTParty.post(
      endpoint,
      body: { user: user }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Webhook-Token' => ENV['WEBHOOK_SECRET_TOKEN'] # Include the secret token in the request headers
      }
    )

    p response # Return the response for further processing if needed
  end
end
