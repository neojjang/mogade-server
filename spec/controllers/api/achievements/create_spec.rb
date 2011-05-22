require 'spec_helper'

describe Api::AchievementsController, :create do
  extend ApiHelper
  
  setup
  it_ensures_a_valid_version :post, :create
  it_ensures_a_valid_context :post, :create
  it_ensures_a_signed_request :post, :create
  it_ensures_a_valid_player :post, :create
  it_ensures_a_valid_achievement :post, :create, Proc.new { {:username => 'leto', :userkey => 'one'} }
  it_ensures_achievement_belongs_to_game :post, :create, Proc.new { {:username => 'leto', :userkey => 'one'} }
  
  it "saves the achievement" do
    achievement = Factory.create(:achievement)
    player = Factory.build(:player)
    EarnedAchievement.should_receive(:create).with(achievement, player).and_return({})
    post :create, ApiHelper.signed_params(@game, {:aid => achievement.id, :username => player.username, :userkey => player.userkey})
  end
  
  
  it "renders the achievement info when first time earned" do
    achievement = Factory.create(:achievement, {:points => 123, :id => Id.new})
    player = Factory.build(:player)
    EarnedAchievement.stub!(:create).with(achievement, player).and_return({})
    post :create, ApiHelper.signed_params(@game, {:aid => achievement.id, :username => player.username, :userkey => player.userkey})
    
    response.status.should == 200
    json = ActiveSupport::JSON.decode(response.body)
    json['id'].should == achievement.id.to_s
    json['points'].should == 123
  end
  
  it "renders a blank response when already earned" do
    achievement = Factory.create(:achievement, {:points => 123, :id => Id.new})
    player = Factory.build(:player)
    
    EarnedAchievement.stub!(:create).with(achievement, player).and_return(nil)
    post :create, ApiHelper.signed_params(@game, {:aid => achievement.id, :username => player.username, :userkey => player.userkey})
    
    response.status.should == 200
    json = ActiveSupport::JSON.decode(response.body)
    json.length.should == 0
  end
end