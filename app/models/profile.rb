class Profile
  include Document
  include ActiveModel::Validations
  mongo_accessor({:name => :n, :game_url => :gu, :enabled => :e, :description => :desc, :developer => :dev, :developer_url => :du, :images => :i})
  
  validates_length_of :name, :minimum => 1, :maximum => 50, :allow_blank => false, :message => 'please enter a name'
  validates_length_of :game_url, :minimum => 0, :maximum => 125, :allow_blank => true, :message => 'please enter a url'
  validates_length_of :description, :minimum => 0, :maximum => 1000, :allow_blank => true, :message => 'please enter a description'
  validates_length_of :developer, :minimum => 1, :maximum => 50, :allow_blank => true, :message => 'please enter a developer'
  validates_length_of :developer_url, :minimum => 1, :maximum => 125, :allow_blank => true, :message => 'please enter a url'
    
  class << self
    def load_for_game(game)
      profile = find_by_id(game.id)
      profile.nil? ? Profile.new({:name => game.name, :_id => game.id, :enabled => false}) : profile
    end
    def create_or_update(name, game_url, developer, developer_url, description, enabled, game)
      profile = load_for_game(game)
      profile.name = name
      profile.game_url = ValueHelper.to_url(game_url)
      profile.developer = developer
      profile.developer_url = ValueHelper.to_url(developer_url)
      profile.description = description
      profile.enabled = enabled == 1
      profile
    end
    def save_image(name, stream, previous = nil)
      Profile.delete_image(previous)
      AWS::S3::S3Object.store(name, stream, Settings.aws['bucket'], {'Cache-Control' => 'public,max-age=31536000'})
    end

    #can't delete images right away because the profile page is cached
    def delete_image(name)
      Store.redis.sadd("cleanup:images:#{Time.now.strftime("%y%m%d")}", name) unless name.nil?
    end
  end
  
  def save_image(filename, data, index)
    return nil if filename.blank? || index > 6 || data.length > Settings.max_image_length
    return nil unless ['.jpg', '.jpeg', '.png', '.gif'].include?(File.extname(filename).downcase)
    
    name = Id.new.to_s + '_' + filename
    self.images = [] if self.images.nil?
    Profile.save_image(name, data, images[index])
    self.images[index] = name
    save!
    name
  end
  
  def remove_image(index)
    return if self.images.nil?
    self.images[index] = nil
    save!
  end
end