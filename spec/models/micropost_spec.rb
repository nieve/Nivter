require 'spec_helper'

describe Micropost do
  let(:user) {FactoryGirl.create(:user)}
  before {@micropost= user.microposts.build(content: 'lorem')}
  subject {@micropost}
  it {should respond_to(:content)}
  it {should respond_to(:user_id)}
  it {should respond_to(:user)}
  it {should be_valid}
  its(:user) {should == user}
  describe "when user id is nil" do
  	before {@micropost.user_id = nil}
  	it {should_not be_valid}
  end
  describe "content property" do
    describe "when nil" do
      before {@micropost.content = nil}
      it {should_not be_valid}
    end
    describe "when beyond 140 characters" do
      before {@micropost.content = 'a' * 141}
      it {should_not be_valid}
    end
  end
  it "should not allow access to user id" do
  	expect {Micropost.new(user_id: 42)}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
  end
end
