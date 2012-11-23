require 'spec_helper'

describe User do
	before {@user = User.new(name: 'kyoko', email:'k@gawa.jp',
									password: 'tokyostory', experience:'mvc', password_confirmation: 'tokyostory')}
	subject {@user}
  it {should respond_to(:admin)}
	it {should respond_to(:email)}
  it {should respond_to(:name)}
  it {should respond_to(:microposts)}
  it {should respond_to(:feed)}
  it {should respond_to(:relationships)}
  it {should respond_to(:followed_users)}
  it {should respond_to(:followers)}
  it {should respond_to(:experience)}
  it {should respond_to(:interested_in)}
  it {should respond_to(:following?)}
  it {should respond_to(:follow!)}
	it {should respond_to(:unfollow!)}
	it { should_not be_accessible :admin }
  it { should respond_to(:password_digest) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
	it {should be_valid}
  describe "microposts association" do
    before {@user.save}
    let!(:old_micro) {FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)}
    let!(:newer_micro) {FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)}
    its(:microposts) {should == [newer_micro, old_micro]}
    it "has non-orphan relations" do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |m|
        Micropost.find_by_id(m.id).should be_nil
      end
    end
    describe "status" do
      let(:unfollowed_micro){FactoryGirl.create(:micropost, user:FactoryGirl.create(:user))}
      its(:feed){should include(newer_micro)}
      its(:feed){should include(old_micro)}
      its(:feed){should_not include(unfollowed_micro)}
    end
    describe "followed users posts in feed" do
      let(:other_user) {FactoryGirl.create(:user)}
      before {@user.follow!(other_user)}
      let(:followed_post){FactoryGirl.create(:micropost, user: other_user)}
      its(:feed) {should include(followed_post)}
    end
  end
  describe "following" do
    let(:other_user) {FactoryGirl.create(:user)}
    before {@user.save; @user.follow!(other_user)}
    it {should be_following(other_user)}
    its(:followed_users) {should include(other_user)}
    describe "unfollow" do
      before {@user.unfollow!(other_user)}
      it {should_not be_following(other_user)}
    end
    describe "followed user" do
      subject {other_user}
      its(:followers) {should include(@user)}
    end
  end
  describe "remember token" do
    before {@user.save}
    its(:remember_token) {should_not be_blank}
  end
  describe "search by experience" do
    before do
      @user.save
      sec_user = User.new(name: 'kyokox', email:'k@gawax.jp', password: 'tokyostoryx', experience:'mvc msmq mssql', password_confirmation: 'tokyostoryx')
      sec_user.save
    end
    let(:search_results) {User.search_by_experience('msmq mvc')}
    specify {search_results.length.should == 1}
    specify {search_results[0].email.should == 'k@gawax.jp'}
    it "should find users only by exact match on tags" do
      User.search_by_experience('mv').length.should == 0
      User.search_by_experience('mvc ms').length.should == 0
      User.search_by_experience('mvc mssql').length.should == 1
      User.search_by_experience('mssql').length.should == 1
      User.search_by_experience('mvc').length.should == 2
    end
  end
	describe "when name is not present" do
		before {@user.name = " "}
		it {should_not be_valid}
	end
	describe "when name is too long" do
		before {@user.name = "a" * 51}
		it {should_not be_valid}
	end
	describe "when email is not present" do
		before {@user.email = " "}
		it {should_not be_valid}
	end
	describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end
  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end
  describe "when email address is already taken" do
  	before do
  		other_user = @user.dup
  		other_user.email = other_user.email.capitalize
  		other_user.save
  	end
  	it {should_not be_valid}
  end
  describe "email address" do
    before {@user.email = "DOWNCASE@EMAIL.COM"; @user.save;}
    it "should be down cased when saved" do
      @user.email.should == "downcase@email.com"
    end
  end
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end
  describe "return value of authenticate method" do
	  before { @user.save }
	  let(:found_user) { User.find_by_email(@user.email) }
	  describe "with valid password" do
	    it { should == found_user.authenticate(@user.password) }
	  end
	  describe "with invalid password" do
	    let(:user_for_invalid_password) { found_user.authenticate("invalid") }
	    it { should_not == user_for_invalid_password }
	    specify { user_for_invalid_password.should be_false }
	  end
	end
	describe "with a password that's too short" do
	  before { @user.password = @user.password_confirmation = "a" * 5 }
	  it { should be_invalid }
	end
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
    it { should be_admin }
  end
end
