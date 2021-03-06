require 'spec_helper'

describe EarnedAchievement, :earned_by_player do
  it "returns the achievements earned by the player for the game" do
    game = FactoryGirl.build(:game)
    achievement1 = FactoryGirl.create(:achievement, {:game_id => game.id})
    achievement2 = FactoryGirl.create(:achievement, {:game_id => game.id})
    achievement4 = FactoryGirl.create(:achievement, {:game_id => game.id})
    player1 = FactoryGirl.build(:player, {:username => 'leto'})
    
    EarnedAchievement.create(achievement1, player1)
    EarnedAchievement.create(achievement2, player1)
    EarnedAchievement.create(FactoryGirl.create(:achievement, {:game_id => Id.new}), player1)
    EarnedAchievement.create(achievement4, FactoryGirl.build(:player, {:username => 'paul'}))
    
    earned = EarnedAchievement.earned_by_player(game, player1)
    earned.length.should == 2
    earned[0].should == achievement1.id
    earned[1].should == achievement2.id
  end
  
  # it "returns an empty array if the player is a loser" do
  #   game = FactoryGirl.build(:game)
  #   achievement1 = FactoryGirl.create(:achievement, {:game_id => game.id})
  #   player1 = FactoryGirl.build(:player, {:username => 'leto'})
  #       
  #   earned = EarnedAchievement.earned_by_player(game, player1)
  #   earned.length.should == 0
  # end
end