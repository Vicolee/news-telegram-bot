# Input: Time intervals in seconds
# Calls BotNewsDispatcher class.
# Output: News scraped and sent to users.
require "#{Rails.root}/app/services/bot_news_dispatcher.rb"
Dir.glob('./app/services/**/*.rb').each { |r| require r }

namespace :telegram do
  desc "Run BotNewsDispatcher, scraping and sending news to telegram users in every specified interval."
  task :dispatch_news, [:time_interval_seconds] => [:environment] do |t, args|
    puts "Starting BotNewsDispatcher..."
    dispatcher = BotNewsDispatcher.new(args[:time_interval_seconds].to_i)
    dispatcher.send_users
  end
end
