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
  it "should not allow access to user id" do
  	expect {Micropost.new(user_id: 42)}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
  end
end
