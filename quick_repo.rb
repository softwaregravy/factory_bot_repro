require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }
  gem "factory_bot", "~> 5.0"
  gem "activerecord"
  gem "sqlite3"
end

require "active_record"
require "factory_bot"
require "minitest/autorun"
require "logger"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  # TODO: Update the schema to include the specific tables or columns necessary
  # to reproduct the bug
  create_table :posts, force: true do |t|
    t.string :body
  end

  create_table :comments, force: true do |t|
    t.bigint :parent_entity_id
  end
end

# TODO: Add any application specific code necessary to reproduce the bug
class Post < ActiveRecord::Base
end

class Comment < ActiveRecord::Base
  belongs_to :parent_entity, class_name: "Post"
end

FactoryBot.define do
  # TODO: Write the factory definitions necessary to reproduce the bug
  factory :post do
    body { "post body" }
    factory :post_extra do
      transient do 
        extra_body { "" }
      end
      body { "Post body " + extra_body }
    end
  end

  factory :comment do 
    transient do 
      extra_body { "commented!" }
    end
    association :parent_entity_id, factory: :post_extra, extra_body: extra_body
  end
end

class FactoryBotTest < Minitest::Test
  def test_factory_bot_stuff
    # TODO: Write a failing test case to demonstrate what isn't working as
    # expected
    body_override = "Body override"

    post = FactoryBot.build(:post_extra, extra_body: body_override)

    assert_equal post.body, "Post body Body override"
  end

  def test_comment
    comment = FactoryBot.build(:comment, extra_body: "from comment")
    assert_equal comment.parent_entity.body, "Post body from comment"
  end
end

# Run the tests with `ruby <filename>`
