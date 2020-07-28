module CryptoNews
  class Analyze
    def initialize(news)
      @news = initialize_news_tags(news)
      @coin_keys = {
        'BTC' => %w[btc bitcoin bitcoiner bitcoiners],
        'BCH' => %w[bch],
        'ETH' => %w[eth ethereum],
        'LTC' => %w[ltc litecoin],
        'XLM' => %w[xlm stellar lumen],
        'XRP' => %w[xrp ripple],
        'BAT' => %w[bat],
        'USDT' => %w[usdt tether fiat],
        'USDC' => %w[usdc],
        'ZIL' => %w[zil zilliqa ziliqa],
        'BNB' => %w[bnb binance],
        'NEO' => %w[neo]
      }
    end

    def initialize_news_tags(news)
      news.each do |article|
        article['tags'] = []
      end
      return news
    end

    def get_coins
      articles = news_highlight
      article_index = 0
      articles.each do |article|
        article_split = article.downcase.gsub!(/[^0-9A-Za-z]/, ' ').split(' ') # Split into list and downcase all capital letters        @coin_keys.each do |coin, keywords|
        @coin_keys.each do |coin, keywords|
          # Add existence of coin to list of tags for current article
          @news[article_index]['tags'] << coin if article_split.to_set.intersect?(keywords.to_set)
        end
        article_index += 1
      end
      remove_untagged_news # Avoid passing untagged news articles to TelegramNews class.
      return @news
    end

    # Outputs title and description of each newly scraped article
    # for get_coins method to do its analyses.
    def news_highlight
      highlights = []
      count = 0
      @news.each do |article|
        highlights[count] = article['title'] + ' ' + article['description']
        count += 1
      end
      return highlights
    end

    def remove_untagged_news
      @news.each_with_index do |article, idx|
        @news.delete_at(idx) if article['tags'].empty?
      end
    end
  end
end
