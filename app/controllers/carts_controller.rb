class CartsController < ApplicationController
  require 'rubygems'
  require 'braintree'
  require 'money'

#Localization for the Money gem
  Money.locale_backend = :i18n

  def index
    #Some definitions for summary stats in the carts#index view
    @carts = Cart.all
    @checkouts = Checkout.all
    @successfulCheckouts = Checkout.where.not(amount: nil)
  end

  def show
    #Helper definitions for info on individual checkouts in the carts#show view
    @cart = Cart.find(params[:id])
    @checkout = @cart.checkouts[0]
  end

  def create
    #Gateway and client token for hosted fields! and need to store the "cart" info in the db
    gateway = Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: 'hqk9y3rc8z3crhwg',
      public_key: '9sgptsv5sgw9kkjd',
      private_key: '31699066076e5a360797d6b8b8f5c28b'
    )
    @client_token = gateway.client_token.generate()
    @cart = Cart.new
    @cart.amount = params[:amount]
    @cart.save
  end
end
