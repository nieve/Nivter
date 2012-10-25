require 'spec_helper'

describe Relationship do
  let(:followed) {FactoryGirl.create(:user)}
  let(:follower) {FactoryGirl.create(:user)}
  let(:relationship) {follower.relationships.build(followed_id: followed.id)}
  subject{relationship}
  it {should be_valid}
  describe "Accessible attributes" do
  	it "should not allow access to follower id" do
  		expect do
  			Relationship.new(follower_id: follower.id)
  		end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
  	end
  end
  describe "follower method" do
  	it {should respond_to(:follower)}
  	it {should respond_to(:followed)}
  	its(:followed) {should == followed}
  	its(:follower) {should == follower}
  end
  describe "without follower" do
  	before {relationship.follower_id = nil}
  	it {should_not be_valid}
  end
  describe "without followed" do
  	before {relationship.followed_id = nil}
  	it {should_not be_valid}
  end
end
