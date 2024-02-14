require 'mercadopago'
class SubscriptionsController < ApplicationController
  def index
    # listar tarjetas
    sdk = Mercadopago::SDK.new('TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197')
    cards_response = sdk.card.list('1666102147-Vr6jz04Pk43GS7')
    cards = cards_response[:response]
    # @cards = cards.map do |card|
    #   {
    #     id: card["id"],
    #     last_four_digits: card["last_four_digits"],
    #     payment_method: card["payment_method"]["name"]
    #   }
    # end
    # @cards.map! { |hash| OpenStruct.new(hash) }

    @cards = cards.map do |card|
      {
        "id": card["id"],
        "last_four_digits": card["last_four_digits"],
        "payment_method": { name: card["payment_method"]["name"] }
      }
    end
  end

  def new_card
  end

  def create_card
    sdk = Mercadopago::SDK.new('TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197')
    card_request = {
      token: params[:token]
    }
    card_response = sdk.card.create('1666102147-Vr6jz04Pk43GS7', card_request)
    card = card_response[:response]

    render json: { message: 'Card created successfully!' }
  end

  def remove_cards
    sdk = Mercadopago::SDK.new('TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197')
    cards_response = sdk.card.list('1666102147-Vr6jz04Pk43GS7')
    cards = cards_response[:response]

    cards.each do |card|
      sdk.card.delete('1666102147-Vr6jz04Pk43GS7', card['id'])
    end

    redirect_to subscriptions_path
  end

  def plans
    response = HTTParty.get(
      'https://api.mercadopago.com/preapproval_plan/search',
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197'
      }
    )
    puts response.body
    @plans = JSON.parse(response.body, symbolize_names: true)
    @plans = @plans[:results]
  end

  def list_payments
    url = 'https://api.mercadopago.com/v1/payments/search'
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197'
    }

    response = HTTParty.get(url, headers: headers)
    @payments = JSON.parse(response.body, symbolize_names: true)
    @payments = @payments[:results]
    @payments = @payments.map do |pay|
      {
        "id": pay[:id],
        # "card": pay[:card]
      }
    end
    render json: @payments
  end

  # create payment and subscription
  def create
    # binding.pry
    # url = 'https://api.mercadopago.com/preapproval'
    # headers = {
    #   'Content-Type' => 'application/json',
    #   'Authorization' => 'Bearer TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197'
    # }
    # body = {
    #   back_url: 'https://www.mercadopago.com.pe',
    #   card_token_id: params['token'],
    #   external_reference: Time.now.to_i.to_s,
    #   payer_email: 'test_payer_01@testuser.com',
    #   preapproval_plan_id: '2c9380848d698da5018d7c5b7cbe0d7c',
    #   reason: 'example subscription',
    #   status: 'authorized'
    # }.to_json

    # response = HTTParty.post(url, headers: headers, body: body)
    # puts params[:token]
    # puts response
    # redirect_to subscriptions_path

    sdk = Mercadopago::SDK.new('TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197')
    payment_request = {
      token: params[:token],
      installments: 1,
      transaction_amount: 100,
      payer: {
        type: 'customer',
        id: '1666102147-Vr6jz04Pk43GS7'
      }
    }

    payment_response = sdk.payment.create(payment_request)
    payment = payment_response[:response]

    if payment['status'] == 'approved'
      puts "Pago aprobado!"
      puts payment
      flash[:notice] = "Pago aprobado! pago id: #{payment['id']}, status: #{payment['status']}"
      redirect_to subscriptions_path
    else
      puts "Pago rechazado!"
      puts payment
      flash[:notice] = "Your notice message here"
      redirect_to subscriptions_path
    end
  end

  def create_payment
    sdk = Mercadopago::SDK.new('TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197')
    binding.pry
    # # crear customer
    # customer_request = {
    #   email: 'test_payer_02@testuser.com'
    # }
    # customer_response = sdk.customer.create(customer_request)
    # customer = customer_response[:response]
    # puts customer

    # # crear tarjeta
    # card_request = {
    #   token: params[:token]
    # }
    # card_response = sdk.card.create(customer['id'], card_request)
    # card = card_response[:response]
    # puts card

    # # crear payment
    payment_request = {
      token: params[:token],
      installments: 3,
      transaction_amount: 100,
      payer: {
        type: 'customer',
        id: '1666102147-Vr6jz04Pk43GS7'
      }
    }
    payment_response = sdk.payment.create(payment_request)
    payment = payment_response[:response]
    # puts payment
  end
end


# curl -X GET \
# 'https://api.mercadopago.com/v1/payments/1316939502'\
#   -H 'Content-Type: application/json' \
#   -H 'Authorization: Bearer TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197' \


# curl -X GET \
#   'https://api.mercadopago.com/v1/payments/search'\
#     -H 'Content-Type: application/json' \
#     -H 'Authorization: Bearer TEST-1973919203979809-020319-259229814a2fe088fed016868af2588b-1665928197' \
