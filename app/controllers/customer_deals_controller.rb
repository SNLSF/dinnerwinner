class CustomerDealsController < ApplicationController

  def show
    @customer_deal = CustomerDeal.find(params[:id])
    @business_id = @customer_deal.deal.business_id
    @pending_deal = @customer_deal.deal
    @requested_business = Business.find(@business_id)
    render json: { requested_business: @requested_business, pending_deal: @pending_deal, customer_deal: @customer_deal }
  end

  def new
  end

  def create
    @new_customer_deal = CustomerDeal.create(customer_id: current_customer.id, party_size: params[:party_size], reservation_time: params[:reservation_time], neighborhoods: params[:neighborhoods])
    render json: {customer: @new_customer_deal}, status: :created
  end

  def edit
    @customer_deal = CustomerDeal.find(params[:id])
    @customer_deal.accepted = true
    @customer = current_customer
    @business_id = @customer_deal.deal.business_id
    @business = Business.find(@business_id)
    if @customer_deal.save
      redirect_to current_customer
      CustomerMailer.deal_accept(@customer_deal.deal, @customer, @business).deliver_later
    end
  end

  def update
    if params[:deal_template]!=nil
      customer_deal = CustomerDeal.find(params[:id])
      customer_deal.update_attributes(deal_id: params[:deal_template])
      notify
    end
    render :json => customer_deal
  end


  def notify
    @client = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']

    @message = @client.messages.create(:body => "First test", :to => current_customer.phone_number, :from => '+15109721904')

    render plain: @message.status
  end

  def destroy
    deal=CustomerDeal.find(params[:id])
    id = deal.id
    deal.destroy
    render :json => {id: params[:id]}
  end

end

