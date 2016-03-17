# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

beth = User.new(
  name:     'Beth',
  email:    'beth@example.com',
  password: 'helloworld'
)
beth.skip_confirmation!
beth.save!

ben = User.new(
  name:     'Ben',
  email:    'ben@example.com',
  password: 'helloworld',
)
ben.skip_confirmation!
ben.save!

kevin = User.new(
  name:     'Kevin',
  email:    'kevin@example.com',
  password: 'helloworld'
)
kevin.skip_confirmation!
kevin.save!


# Set up subscription plan and subscriber
stripe_token = Stripe::Token.create(
  :card => {
    :number => "4242424242424242",
    :exp_month => 3,
    :exp_year => 2017,
    :cvc => "314"
  }
)

# Must not exist in Stripe yet. Should be deleted if it does.
subscription_plan = SubscriptionPlan.create(
  amount: 400,
  interval: "month",
  stripe_id: "testplan",
  name: "Test Plan"
)

sub_params = {
  plan: subscription_plan,
  stripeEmail: kevin.email,
  stripeToken: stripe_token.id,
  owner: kevin
}

Payola::CreateSubscription.call(sub_params, kevin)
kevin.account_status = "subscriber"
kevin.save!

users = User.all

# Add in expiration date normally set by confirming acocunt
users.each do |user|
  user.expiration_date = user.confirmed_at + 7.days
  user.save!
end

phone_numbers = ["(608) 286-2025", "(334) 544-0027", "(920) 944-9479", "(757) 687-0169"]

12.times do
  Contact.create!(
    user: users.sample,
    name: Faker::Name.name,
    phone: phone_numbers.sample
  )
end

contacts = Contact.all


15.times do
  zones = ActiveSupport::TimeZone.us_zones.map {|zone| zone.name }
  time = Faker::Time.forward(30).strftime("%H:%M")
  start_date = Faker::Date.forward(30).strftime("%Y-%m-%d")
  zone = zones.sample

  contact = contacts.sample
  schedule = Schedule.create!(
    contact: contact,
    message: Faker::Lorem.sentence
  )
  Frequency.create!(
    schedule: schedule,
    repeat: Faker::Boolean.boolean,
    sunday: Faker::Boolean.boolean,
    monday: Faker::Boolean.boolean,
    tuesday: Faker::Boolean.boolean,
    wednesday: Faker::Boolean.boolean,
    thursday: Faker::Boolean.boolean,
    friday: Faker::Boolean.boolean,
    saturday: Faker::Boolean.boolean,
    timezone: zone,
    time: time,
    start_date: start_date,
    start_datetime: Timeliness.parse(start_date + ' ' + time, zone: zone)
  )

  # schedule.create_occurence_and_scheduled_call
end
