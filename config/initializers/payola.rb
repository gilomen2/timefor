# config/initializers/payola.rb
Payola.configure do |config|
  config.secret_key = ENV['STRIPE_SECRET_KEY']
  config.publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']
  # Example subscription:
  #
  # config.subscribe 'payola.package.sale.finished' do |sale|
  #   EmailSender.send_an_email(sale.email)
  # end
  #
  # In addition to any event that Stripe sends, you can subscribe
  # to the following special payola events:
  #
  #  - payola.<sellable class>.sale.finished
  #  - payola.<sellable class>.sale.refunded
  #  - payola.<sellable class>.sale.failed
  #
  # These events consume a Payola::Sale, not a Stripe::Event
  #
  # Example charge verifier:
  #
  # config.charge_verifier = lambda do |sale|
  #   raise "Nope!" if sale.email.includes?('yahoo.com')
  # end

  config.support_email = 'support@timefor.io'

  # Keep this subscription unless you want to disable refund handling
  config.subscribe 'charge.refunded' do |event|
    sale = Payola::Sale.find_by(stripe_id: event.data.object.id)
    sale.refund!
  end

  config.subscribe 'customer.subscription.deleted' do |event|
    sub = Payola::Subscription.find_by(stripe_customer_id: event.data.object.customer)
    if sub
    	user = User.find(sub.owner_id)
    	user.cancel_subscription(event.id)
    end
    Payola::SyncSubscription.call(event)
  end

  config.subscribe 'customer.subscription.updated' do |event|
    Payola::UpdateSubscription.call(event)
  end

  config.subscribe 'invoice.payment_failed' do |event|
    sub = Payola::Subscription.find_by(stripe_customer_id: event.data.object.customer)
    if sub
      user = User.find(sub.owner_id)
      user.handle_default
    end
    Payola::SyncSubscription.call(event)
  end

  config.subscribe 'customer.subscription.updated' do |event|
    sub = Payola::Subscription.find_by(stripe_customer_id: event.data.object.customer)
    if sub
      user = User.find(sub.owner_id)
      user.update_user_status(event.id)
    end
  end

  config.subscribe 'invoice.payment_succeeded' do |event|
    sub = Payola::Subscription.find_by(stripe_customer_id: event.data.object.customer)
    if sub
      user = User.find(sub.owner_id)
      user.update_next_billing_date(event.id)
    end
  end
end
