# encoding: utf-8

# http://raa.ruby-lang.org/project/ruby-aws/
# http://www.jeffreyjason.com/2010/07/12/amazon-product-advertising-api-w-ruby/
# http://docs.amazonwebservices.com/AWSECommerceService/2010-11-01/DG/
# http://associates-amazon.s3.amazonaws.com/signed-requests/helper/index.html
# see config/.amazonrc file for configuration options

require 'amazon/aws'
require 'amazon/aws/search'
class Artwork
  include Amazon::AWS
  include Amazon::AWS::Search

  def initialize(artist, album, spotify_track = nil)
    @spotify_track = spotify_track
    @artist = artist
    @album = album
  end

  def get
    if @spotify_track
      load_image_from_spotify
    else
      load_image_from_amazon
    end
  end

  private

  def load_image_from_spotify
    @spotify_track.album.images.first['url']
  end

  def load_image_from_amazon
    return if not_enough_track_info?
    response = Amazon::AWS.item_search(
      'Music',
      {
        'Artist' => clean_up_attribs(@artist),
        'Title' => clean_up_attribs(@album)
      }
    )

    if image = response.item_search_response.items.item.first.large_image
      image.url.to_s
    end
  rescue Amazon::AWS::Error => e
    Rails.logger.error "Amazon Error: #{e.message}"
    Rails.logger.error "AmazonArtwork for artist: #{@artist} album: #{@album}"
  end

  def clean_up_attribs(str)
    # just removing things like (1 of 2) in the title
    # yields much better results
    str = str.gsub(/\(.*\)?/,'')
    str.strip
  end

  # Returns true is the track has all the information needed to run an Amazon search
  def not_enough_track_info?
    @artist.blank? || @album.blank?
  end

end
