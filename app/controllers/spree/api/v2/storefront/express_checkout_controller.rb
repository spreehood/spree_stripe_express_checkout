# frozen_string_literal: true

module Spree
  module Api
    module V2
      module Storefront
        class ExpressCheckoutController < ::Spree::Api::V2::BaseController
          # before_action :require_spree_current_user

          def create
            @order = if params[:order_id].present?
                       Spree::Order.find(params[:order_id])
                     else
                       Spree::Order.find_by(number: params[:order_number])
                     end

            @order.next

            # Attach the address of the stock location to the order
            attach_address

            # Attach the shipping method to the order
            attach_shipping_method

            # Process the payment
            payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::StripeExpressCheckout')

            payment = @order.payments.build(
              payment_method_id: payment_method.id,
              response_code: params[:payment_intent_id],
              amount: @order.total,
              source: create_source(payment_method),
              state: 'checkout'
            )

            begin
              if payment.save
                if payment.state == 'checkout'
                  payment.process!
                end

                @order.update!(email: 'no_email@email.com', state: 'complete')

                render json: { message: 'Order and Payment created successfully' }, status: :ok
              else
                render json: { error: 'Payment could not be completed' }, status: :unprocessable_entity
              end
            rescue StateMachines::InvalidTransition => e
              render json: { error: e.message }, status: :unprocessable_entity
            rescue StandardError => e
              render json: { error: e.message }, status: :unprocessable_entity
            end
          end

          private

          def attach_address
            default_address = Spree::Address.find_by(label: 'default')

            if default_address.present?
              @order.update(billing_address: default_address)
            else
              country = Spree::Country.find_by(iso: 'US')
              state = country.states.first
              address = Spree::Address.create!(first_name: 'Anonymous', last_name: 'User', address1: 'Kathmandu',
                                                            city: 'Kathmandu', zipcode: '12345', phone: '1234567890',
                                                            state: , label: 'default', country: )
              @order.update(billing_address: address)
            end

            @order.update!(use_billing: true)
            @order.next
          end

          def attach_shipping_method
            shipping_rates = @order.shipments.first.shipping_rates
            targeted_rate = shipping_rates.find_by(cost: 0)

            shipping_rates.update_all(selected: false)
            targeted_rate.update!(selected: true)

            @order.shipments.first.update_amounts
            @order.update_totals
            @order.persist_totals
            @order.next
          end

          def create_source(payment_method)
            Spree::StripeExpressCheckoutSource.create!(
              payment_intent_id: params[:payment_intent_id],
              payment_intent_secret: params[:payment_intent_secret],
              payment_method_id: payment_method.id
            )
          end
        end
      end
    end
  end
end
