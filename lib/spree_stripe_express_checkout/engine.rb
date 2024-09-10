module SpreeStripeExpressCheckout
  class Engine < Rails::Engine
    require 'spree/core'
    require 'spree_gateway'
    isolate_namespace Spree
    engine_name 'spree_stripe_express_checkout'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_stripe_express_checkout.environment', before: :load_config_initializers do |_app|
      SpreeStripeExpressCheckout::Config = SpreeStripeExpressCheckout::Configuration.new
    end

    config.after_initialize do |app|
      require_dependency 'spree/gateway/stripe_express_checkout'
      app.config.spree.payment_methods << Spree::Gateway::StripeExpressCheckout
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
