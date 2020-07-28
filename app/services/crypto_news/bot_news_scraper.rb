require 'httparty'
require 'active_support/all'
require 'nokogiri'
require 'nokogumbo'

module CryptoNews
  class BotNewsScraper
    def initialize
      @url = Rails.application.credentials.telegram[:news_api]
    end

    # scrape_articles takes in the time interval to scrape and returns
    # a list of newly posted articles from the url provided.
    def scrape_articles(interval, last_article_sent)
      scraped = scrape_url(@url)
      last_article_sent = scraped[0]['date'] if last_article_sent.nil?
      new_articles, last_article_sent = retrieve_new_articles(scraped, last_article_sent)
      if new_articles.empty?
        puts "There are no new articles in the last #{interval} seconds."
      else
        new_articles = parse_articles(new_articles) # parse HTML. Remove HTML tags.
        puts "The new articles in the past #{interval} seconds are: #{new_articles}."
      end
      return new_articles, last_article_sent
    end

    private

    def scrape_url(url)
      response = HTTParty.get(url)
      scraped_articles = response.parsed_response['articles']
      return scraped_articles
    end

    def parse_articles(news)
      news.each do |article|
        noko_title = Nokogiri.HTML5(article['title'])
        noko_description = Nokogiri.HTML5(article['description'])
        article['title'] = noko_title.text
        article['description'] = noko_description.text
      end
      return news
    end

    # retrieve_new_articles takes in articles from the url and returns newly
    # posted articles.
    # Input: parsed_articles => Articles scraped from the url.
    #      : last_article_sent => Time of the last article sent from the
    # previous interval.
    # barricade_article: Time of the last article sent from the previous interval
    # Output: last_article_sent => Time of the last article sent in current interval.
    #       : new_articles => List of newly posted articles since the last interval.
    def retrieve_new_articles(parsed_articles, last_article_sent)
      i = 0
      new_articles = [] # Empty the last interval's new articles list
      barricade_article = last_article_sent # Sets the last article from the previous interval to be the current interval's "barricade".
      Time.zone = 'Singapore'
      current_time = Time.zone.now.strftime("%FT%T.%L%z") # The current time that the scraping occurs.
      while current_time > barricade_article # Compare time of current article appended with the previous scrape interval's article time.
        break if parsed_articles[i]['date'] == barricade_article
        new_articles << parsed_articles[i]
        # puts "Appended article with title #{parsed_articles[i]['title']} to the new articles list"
        current_time = parsed_articles[i]['date'] # With each iteration, current time changes to the "date" index of the current article appended to "new articles"
        i += 1 # Move down to the next article
      end
      last_article_sent = parsed_articles[0]['date']
      return new_articles, last_article_sent
    end
  end
end
