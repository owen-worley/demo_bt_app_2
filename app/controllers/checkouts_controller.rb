class CheckoutsController < ApplicationController
  require 'rubygems'
  require 'braintree'

  def transaction(gateway, amount, customer_id, device_data, sfs_bool)
    gateway.transaction.sale(
      amount: amount,
      customer_id: customer_id,
      device_data: device_data,
      options: {
        submit_for_settlement: sfs_bool
      }
    )
  end

  def vault(gateway, nonce, first_name, last_name, email, device_data, postal_code)
    gateway.customer.create(
      payment_method_nonce: nonce,
      first_name: first_name,
      last_name: last_name,
      email: email,
      device_data: device_data,
      credit_card: {
        billing_address: {
          first_name: first_name,
          last_name: last_name,
          postal_code: postal_code
        },
        options: {
          verify_card: 'true'
        }
      }
    )
  end

  def successResult(transaction_id)
    #Helper for creating confirmation page text
    @title = "Payment Confirmation"
    @message = "Payment Accepted! Transaction confirmation code " + transaction_id + ". Please print this page for your records."
    #Note that @link is an empty string for successful txns, as we are using @link to provide a link back to the welcome view to retry checkout for failed attempts
    @link = ""
  end

  def failureResult()
    #Helper for creating failed payment page text
    @title = "Payment Failed"
    @message = "Please provide another form of payment. "
    @link = "Click here to return to the checkout page."
  end

  def create
    #Gateway for txn.sale and customer.create
    gateway = Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: 'hqk9y3rc8z3crhwg',
      public_key: '9sgptsv5sgw9kkjd',
      private_key: '31699066076e5a360797d6b8b8f5c28b'
    )
    #New db row for the txn/customer info
    @checkout = Cart.find(params[:cart_id]).checkouts.new
    #Getting the card type from the tokenization payload
    @checkout.card_type = params[:card_type]
    customer_result = vault(gateway, params[:payment_method_nonce], params[:first_name], params[:last_name], params[:email], params[:data_collector], params[:postal_code])
    if customer_result.success?
      @checkout.verification_id = customer_result.customer.payment_methods[0].verification.id
      customer_id = customer_result.customer.id
      @checkout.customer_id = customer_id
      @checkout.postal_code = params[:postal_code]
      @checkout.email = params[:email]
      @checkout.first_name = params[:first_name]
      @checkout.last_name = params[:last_name]
      @checkout.verification_success = true
      @checkout.verification_result = "success"
      transaction_result = transaction(gateway, params[:amount], customer_id, params[:data_collector], true)
      if transaction_result.success?
        successResult(transaction_result.transaction.id)
        @checkout.transaction_id = transaction_result.transaction.id
        @checkout.transaction_success = true
        @checkout.transaction_result = "success"
        #Note that we wait to set the "amount" value until we know that the txn is successful.
        #This will come in handy for the way that I calculate summary statistics...
        @checkout.amount = params[:amount]
      else
        failureResult()
        #Checking that a transaction result exists before querying it to prevent errors.
        if transaction_result.respond_to?('transaction')
          @checkout.transaction_id = transaction_result.transaction.id
          @checkout.transaction_success = false
          if transaction_result.transaction.status == 'processor_declined'
            @checkout.transaction_result = "declined"
          elsif transaction_result.transaction.status == 'gateway_rejected'
            @checkout.transaction_result = "gateway rejected"
          else
            @checkout.transaction_result = "failed"
          end
        end
      end
    else
      failureResult()
      #Likewise, checking that a verification result exists before quering it to prevent errors.
      if customer_result.respond_to?('verification')
        @checkout.verification_success = false
        @checkout.verification_id = customer_result.verification.id
        if customer_result.verification.status == 'processor_declined'
          @checkout.verification_result = "declined"
        elsif customer_result.verification.status == 'gateway_rejected'
          @checkout.verification_result = "gateway rejected"
        else
          @checkout.verification_result = "failed"
        end
      end
    end
    @checkout.save
  end

end
