require 'spec_helper'
require './deploy/jobs/cleaner'

describe Cleaner, 'clean scores' do

  it "clears our daily scores older than 3 days" do
    Factory.create(:score, {:daily => Factory.build(:score_data, {:data => 1, :stamp => Time.now.utc - 43400})})
    Factory.create(:score, {:daily => Factory.build(:score_data, {:data => 2, :stamp => Time.now.utc - 1 * 86400})})
    Factory.create(:score, {:daily => Factory.build(:score_data, {:data => 3, :stamp => Time.now.utc - 2 * 86400})})
    Factory.create(:score, {:daily => Factory.build(:score_data, {:data => 4, :stamp => Time.now.utc - 3 * 86400})})
    Factory.create(:score, {:daily => Factory.build(:score_data, {:data => 5, :stamp => Time.now.utc - 4 * 86400})})
    Factory.create(:score, {:daily => Factory.build(:score_data, {:data => 6, :stamp => Time.now.utc - 5 * 86400})})
    
    Cleaner.new.clean_scores
    Score.count.should == 6
    assert_scrubbed(:daily, [4, 5, 6])
  end
  
  it "clears our weekly scores older than 10 days" do
    Factory.create(:score, {:weekly => Factory.build(:score_data, {:data => 1, :stamp => Time.now.utc - 43400})})
    Factory.create(:score, {:weekly => Factory.build(:score_data, {:data => 2, :stamp => Time.now.utc - 4 * 86400})})
    Factory.create(:score, {:weekly => Factory.build(:score_data, {:data => 3, :stamp => Time.now.utc - 9 * 86400})})
    Factory.create(:score, {:weekly => Factory.build(:score_data, {:data => 4, :stamp => Time.now.utc - 11 * 86400})})
    Factory.create(:score, {:weekly => Factory.build(:score_data, {:data => 5, :stamp => Time.now.utc - 12 * 86400})})
    
    Cleaner.new.clean_scores
    Score.count.should == 5
    assert_scrubbed(:weekly, [4, 5])
  end
  
  
  private
  def assert_scrubbed(scope, ids)
    Score.find.each do |score|
      ids.include?(score.send("#{scope}").data).should be_false
    end
  end
end