require 'json'

class Insights

  attr_reader :video_statistics
  TITLE_DIVIDER = " | "

  def initialize(json_filename)
    @video_statistics = parse(json_filename)
  end

  def get_influencer_name
    title = @video_statistics[0]["title"]
    title.partition(TITLE_DIVIDER).last
  end

  def get_video_with_highest_likes_ratio
    get_names_with_likes_ratio.key(get_names_with_likes_ratio.values.max)
  end

  def mean_likes_ratio
    ratios = get_names_with_likes_ratio.values
    total = ratios.inject { |sum, item| sum + item }.to_f
    mean = total / ratios.length
    mean.round(1)
  end

  def compute_total_views
    sum = 0
    @video_statistics.each { |video| sum += video["views"] }
    sum
  end

  private

  def parse(json_filename)
    file = open(json_filename)
    json = file.read
    parsed_json = JSON.parse(json)
    parsed_json["videos"]
  end

  def compute_likes_ratio(likes, dislikes)
    total = likes + dislikes
    (likes.to_f / total.to_f) * 100
  end

  def get_names_with_likes_ratio
    titles_to_ratios = {}

    @video_statistics.each do |video|
      ratio = compute_likes_ratio(video["likes"], video["dislikes"])
      video_name = isolate_video_name(video["title"])
      titles_to_ratios[video_name] = ratio
    end

    titles_to_ratios
  end

  def isolate_video_name(title)
    title.partition(TITLE_DIVIDER).first
  end

end
