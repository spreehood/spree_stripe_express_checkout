module Spree
  module OrderDecorator
    def self.prepended(base)
      base.checkout_flow do
        go_to_state :address, unless: ->(order) { order.express_checkout? }
        go_to_state :delivery, if: ->(order) { order.delivery_required? && !order.express_checkout? }
        go_to_state :payment, if: ->(order) { order.payment? || order.payment_required? }
        go_to_state :confirm, if: ->(order) { order.confirmation_required? }
        go_to_state :complete

        # Remove transition from delivery to confirm if confirmation is not required
        remove_transition from: :delivery, to: :confirm, unless: ->(order) { order.confirmation_required? }
      end
    end

    # Helper method to check if express checkout is enabled
    def express_checkout?
      # express_checkout == true
      true
    end
  end
end

# Prepend the decorator to the Spree::Order model
Spree::Order.prepend(Spree::OrderDecorator)
