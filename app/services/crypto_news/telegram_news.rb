require 'telegram/bot'

module CryptoNews
  class TelegramNews
    def initialize(news)
      token = Rails.application.credentials.telegram[:bot]
      @news = news
      @api = Telegram::Bot::Api.new(token)
    end

    def send_news(options={})
      ::User.all.each do |user|
        next if user.status == '/pause' || user.coin_list.empty?
        highlights = ''
        counter = 0
        @news.each do |article|
          if user.coin_list.to_set.intersect?(article['tags'].to_set)
            counter += 1
            highlights << "#{counter}. " + "*#{article['title']}*" + ".\n" + process_description(article['description']) + '...' + "\n" + "Read more [here](#{article['link']})" + "\n\n"
          end
        end
        if counter == 1 # Message for case where user only receives one article (no counter).
          highlights = "*#{@news[0]['title']}*" + "\n" + process_description(@news[0]['description']) + '...' + "\n" + "Read more [here](#{@news[0]['link']})" + "\n\n"
        end
        @api.call('sendMessage', chat_id: user.telegram_id, text: highlights, parse_mode: 'Markdown') if (!highlights.empty?) # To avoid sending empty messages
      end
    end

    # Input article's description
    # Outputs shortened version to send telegram users.
    def process_description(description)
      description = description.split(' ')
      description = description.take(25).join(' ')
      return description
    end
  end
end
