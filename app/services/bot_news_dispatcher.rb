# frozen_string_literal: false
require 'active_support/all'


# BotNewsDispatcher takes the input time interval and scrapes the cryptocurrency
# articles. Returns relevant news to users who have indicated interest via the
# telegram bot.
class BotNewsDispatcher
  def initialize(interval)
    @interval = interval
    @scraper = CryptoNews::BotNewsScraper.new
  end

  def send_users
    time_elapsed = 0
    last_article_sent = nil
    Time.zone = 'Singapore' # Timezone has to match the date/time of the News API
    loop do
      sleep(@interval)
      puts "Date/Time: #{Time.zone.now.strftime("%F %T %z")}. Time elapsed: #{time_elapsed += @interval} seconds."
      new_articles, last_article_sent = @scraper.scrape_articles(@interval, last_article_sent)
      next if new_articles.empty?
      new_articles = analyze_coins(new_articles)
      next if new_articles.empty?
      dispatch_news(new_articles)
    end
  end

  private

  # Inputs new articles scraped from BotNewsScraper class scrape_articles method
  # Outputs news articles with coin tags. Those without are removed from
  # new_articles list.
  def analyze_coins(new_articles)
    analyzer = CryptoNews::Analyze.new(new_articles)
    new_articles = analyzer.get_coins # Tags articles. Removes untagged articles
    return new_articles
  end

  # Inputs new articles that have been analysed by analyze_coins method.
  # Sends relevant articles to users who have indicated interest via telegram.
  def dispatch_news(new_articles)
    dispatcher = CryptoNews::TelegramNews.new(new_articles)
    dispatcher.send_news
  end
end
