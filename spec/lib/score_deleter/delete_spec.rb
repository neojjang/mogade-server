require 'spec_helper'

describe ScoreDeleter, :delete do
  it "deletes for a username match for all scopes" do
    leaderboard = Factory.build(:leaderboard)
    [LeaderboardScope::Daily, LeaderboardScope::Weekly, LeaderboardScope::Overall].each do |scope|
      leaderboard = Factory.build(:leaderboard)
      name = Score.scope_to_name(scope)
      
      Factory.create(:score, {:username => 'baron', :leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 23})})
      Factory.create(:score, {:username => 'baron', :leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 33})})
      Factory.create(:score, {:username => 'baron', :leaderboard_id => leaderboard.id})

      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::UserName, 3, 'leto')
      Score.count.should == 3
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::UserName, 3, 'baron')
      Score.count({name => {'$ne' => nil}}).should == 0
      Score.remove
    end
  end

  it "deletes for a point less than match for all scopes" do
    leaderboard = Factory.build(:leaderboard)
    [LeaderboardScope::Daily, LeaderboardScope::Weekly, LeaderboardScope::Overall].each do |scope|
      name = Score.scope_to_name(scope)
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 5})})
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 1, 1)
      Score.count.should == 3
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 1, 5)
      Score.count({name => {'$ne' => nil}}).should == 1
      Score.remove
    end
  end
  
  it "deletes point less than or equal match for all scopes" do
    leaderboard = Factory.build(:leaderboard)
    [LeaderboardScope::Daily, LeaderboardScope::Weekly, LeaderboardScope::Overall].each do |scope|
      name = Score.scope_to_name(scope)
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 5})})

      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 2, 2)
      Score.count.should == 3
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 2, 5)
      Score.count({name => {'$ne' => nil}}).should == 0
      Score.remove
    end
  end
  
  it "deletes point equal match for all scopes" do
    leaderboard = Factory.build(:leaderboard)
    [LeaderboardScope::Daily, LeaderboardScope::Weekly, LeaderboardScope::Overall].each do |scope|
      name = Score.scope_to_name(scope)
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 5})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})

      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 3, 6)
      Score.count.should == 3
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 3, 4)
      Score.count({name => {'$ne' => nil}}).should == 1
      Score.remove
    end
  end
  
  it "deletes point greater than or equal match for all scopes" do
    leaderboard = Factory.build(:leaderboard)
    [LeaderboardScope::Daily, LeaderboardScope::Weekly, LeaderboardScope::Overall].each do |scope|
      name = Score.scope_to_name(scope)
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 5})})
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 4, 7)
      Score.count.should == 3
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 4, 4)
      Score.count({name => {'$ne' => nil}}).should == 0
      Score.remove
    end
  end
  
  it "returns the count of for a point greater than match for all scopes" do
    leaderboard = Factory.build(:leaderboard)
    [LeaderboardScope::Daily, LeaderboardScope::Weekly, LeaderboardScope::Overall].each do |scope|
      name = Score.scope_to_name(scope)
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 4})})
      Factory.create(:score, {:leaderboard_id => leaderboard.id, name => Factory.build(:score_data, {:points => 5})})

      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 5, 10)
      name = Score.scope_to_name(scope)
      
      ScoreDeleter.delete(leaderboard, scope, ScoreDeleterField::Points, 5, 4)
      Score.count({name => {'$ne' => nil}}).should == 2
      Score.remove
    end
  end
end