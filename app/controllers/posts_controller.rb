class PostsController < ApplicationController
  def index
    unless params['tags']
      render json: JSON.pretty_generate({ error: "Tags parameter is required" })
      return
    end

    seen_posts = {}
    tags = params['tags'].split(",")
    tags.each do |tag|
      parsed_response = fetch_posts_for_tag(tag)
      seen_posts = total_posts(parsed_response['posts'], seen_posts)
    end
    errors = {}

    seen_posts = handle_sort(params['sortBy'], params['direction'], seen_posts)

    if params['direction'] && !['asc', 'desc'].include?(params['direction'])
      errors['direction'] = "direction parameter is invalid"
    end

    if params['sortBy'] && !['id', 'likes', 'popularity', 'reads'].include?(params['sortBy'])
      errors['sortBy'] = 'sortBy parameter is invalid'
    end

    if errors.keys.empty?
      render json: JSON.pretty_generate({ posts: seen_posts.values })
    else
      render json: JSON.pretty_generate(errors)
    end
  end

  private

  def fetch_posts_for_tag(tag)
    uri = URI("https://hatchways.io/api/assessment/blog/posts?tag=#{tag}")
    JSON.parse(Net::HTTP.get(uri))
  end

  def handle_sort(sortBy, direction, seen_posts)
    if (sort_by_key = params['sortBy'])
      seen_posts = seen_posts.sort_by { |_, post| post[sort_by_key] }

      if params['direction'] == "desc"
        seen_posts = seen_posts.reverse
      end
    end
    seen_posts = seen_posts.to_h
  end

  def total_posts(new_posts, all_posts = {})
    new_posts.each do |post|
      unless all_posts[post["id"]]
        all_posts[post["id"]] = post
      end
    end
    all_posts
  end
end
