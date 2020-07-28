# frozen_string_literal: false
class User < ApplicationRecord
  validates_uniqueness_of :telegram_id
end
