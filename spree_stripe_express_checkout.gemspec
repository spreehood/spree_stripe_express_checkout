# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_stripe_express_checkout/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_stripe_express_checkout'
  s.version     = SpreeStripeExpressCheckout::VERSION
  s.summary     = "Spree Commerce Stripe express checkout Extension"
  s.required_ruby_version = '>= 3.0'

  s.author    = 'You'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/your-github-handle/spree_stripe_express_checkout'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '>= 4.9.0'
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'spree_dev_tools'
end
