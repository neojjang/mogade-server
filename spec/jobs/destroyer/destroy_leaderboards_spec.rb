require 'spec_helper'
require './deploy/jobs/destroyer'

describe Destroyer, 'destroy leaderboards' do
  it "destroys the ranks associated with a leaderboard" do
    leaderboard1 = FactoryGirl.create(:leaderboard, {:id => Id.new})
    leaderboard2 = FactoryGirl.create(:leaderboard, {:id => Id.new})
    old =  Time.now - 3148843
    Rank.save(leaderboard1, LeaderboardScope::Daily, 'u1', 500)
    Rank.save(leaderboard1, LeaderboardScope::Weekly, 'u1', 500)
    Rank.save(leaderboard1, LeaderboardScope::Overall, 'u1', 550)
    Rank.save(leaderboard1, LeaderboardScope::Daily, 'u2', 600)
    Rank.save(leaderboard2, LeaderboardScope::Daily, 'u4', 500)
    Rank.save(leaderboard2, LeaderboardScope::Overall, 'u2', 500)
    Time.stub!(:now).and_return(old)
    Rank.save(leaderboard1, LeaderboardScope::Daily, 'u2', 600)
    Rank.save(leaderboard2, LeaderboardScope::Daily, 'u1', 500)
    
    
    Store.redis.sadd('cleanup:leaderboards', leaderboard1.id)
    Destroyer.new.destroy_leaderboards

    Store.redis.keys("*:#{leaderboard1.id}*").length.should == 0
    Store.redis.keys("*:#{leaderboard2.id}*").length.should == 3
  end
  
  it "destroys the high scores associated with a leaderboard" do
    leaderboard1 = FactoryGirl.create(:leaderboard, {:id => Id.new})
    leaderboard2 = FactoryGirl.create(:leaderboard, {:id => Id.new})
    FactoryGirl.create(:score, {:leaderboard_id => leaderboard1.id})
    FactoryGirl.create(:score, {:leaderboard_id => leaderboard2.id})

    Store.redis.sadd('cleanup:leaderboards', leaderboard1.id)
    Destroyer.new.destroy_leaderboards
    
    Score.count({:leaderboard_id => leaderboard1.id}).should == 0
    Score.count({:leaderboard_id => leaderboard2.id}).should == 1
  end
  
  it "removes the leaderboard id from the destruction queue" do
    leaderboard = FactoryGirl.build(:leaderboard, {:id => Id.new})
    Store.redis.sadd('cleanup:leaderboards', leaderboard.id)
    Destroyer.new.destroy_leaderboards
    Store.redis.scard('cleanup:leaderboards').should == 0
  end
  
  it "doesn't do anything if there are no leaderboard to DESTROY" do
    Destroyer.new.destroy_leaderboards
  end
end