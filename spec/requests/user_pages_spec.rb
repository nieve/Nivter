require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'stabat matter') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'de la rosa') }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
    it { should have_selector('#tagdisplay .sotag', text: "msmq")}
    it { should have_selector('#interestdisplay .sotag', text: "nancyfx")}
    it { should have_content(m1.content) }
    it { should have_content(m2.content) }
    it { should have_content(user.microposts.count) }
    describe "no tags" do
      let(:boring_user) {FactoryGirl.create(:user, experience: '', interested_in: '')}
      before {visit user_path(boring_user)}
      it {should have_selector('#tagdisplay', text: "none indicated")}
      it {should have_selector('#interestdisplay', text: "none indicated")}
    end
    describe "follow button" do
      let(:other_user) {FactoryGirl.create(:user)}
      before {sign_in(user)}
      describe "following a user" do
        before {visit user_path(other_user)}
        it "should increment the followed user count" do
          expect {click_button "Follow"}.to change(user.followed_users, :count).by(1)
        end
        it "should increment the followers user count" do
          expect {click_button "Follow"}.to change(other_user.followers, :count).by(1)
        end
        describe "toggling the follow button" do
          before {click_button "Follow"}
          it {should have_selector('input', value: 'Unfollow')}
        end
      end
      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end
        it "should decrement followed user count"do
          expect {click_button "Unfollow"}.to change(user.followed_users, :count).by(-1)
        end
        it "should decrement followers user count"do
          expect {click_button "Unfollow"}.to change(other_user.followers, :count).by(-1)
        end
        describe "toggling the follow button" do
          before {click_button "Unfollow"}
          it {should have_selector('input', value: 'Follow')}
        end
      end
    end
  end
  describe "signup" do
    before { visit signup_path }
    let(:submit) { "Submit" }
		it {should have_selector('h1', text:'Sign up')}
		it {should have_selector('title', text:'Sign up')}
    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end
    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirm Password", with: "foobar"
        select "France", from: "Country"
        fill_in "City", with: "Lille"
      end
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      describe "after saving the user" do
        before {click_button submit}
        it {should have_link('Sign out')}
      end
      describe "followed by signout" do
        before {click_button submit; click_link 'Sign out'}
        it {should have_link('Sign in')}
      end
    end
  end
  describe "edit" do
    let(:user){FactoryGirl.create(:user)}
    before do 
      sign_in user
      visit edit_user_path(user)
    end
    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit #{user.name}") }
      it { should have_selector('.sotag', text: "mvc") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end
    describe "with invalid information" do
      before { click_button "Submit" }
      it { should have_content('error') }
    end
    describe "with valid information" do
      let(:new_name){"Example User"}
      let(:new_email){"user@example.com"}
      before do
        fill_in "Name",         with: new_name
        fill_in "Email",        with: new_email
        fill_in "Password",     with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Submit"
      end
      it {should have_selector('title', text: new_name)}
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify {user.reload.name.should == new_name}
      specify {user.reload.email.should == new_email}
    end
  end
  describe "search" do
    describe "by experience" do
      let(:user) {FactoryGirl.create(:user)}
      before(:all) do
        30.times {FactoryGirl.create(:user)}
        user.experience = "asp.net"
        user.save
      end
      before(:each) do
        sign_in user
        visit users_path + '/?search=asp.net'
      end
      after(:all) do
        User.delete_all
        user.experience = "msmq mvc"
        user.save
      end
      it "should display search results" do
        page.should have_selector('li', text: user.name)
      end
      it "should not display unfound users" do
        User.where("name != '#{user.name}'").each do |u|
          page.should_not have_link(u.name, href: user_path(u))
        end
      end
    end
    describe "by location" do
      let(:user) {FactoryGirl.create(:user)}
      before(:all) do
        9.times {FactoryGirl.create(:user)}
        user.experience = "mssql"
        user.city = "Lyon"
        user.save
      end
      before(:each) do
        sign_in user
      end
      after(:all) do
        User.delete_all
        user.city = "Lille"
        user.save
      end
      it "should not display unfound users" do
        visit users_path + '/?search=msmq%20mvc'
        page.should_not have_selector('li', text: user.name)
      end
      it "should display search results" do
        visit users_path + '/?search=msmq%20mvc&country=France&city=Lille'
        User.where("city != '#{user.city}'").each do |u|
          page.should have_link(u.name, href: user_path(u))
        end
      end
      it "should not display non local users" do
        visit users_path + '/?search=msmq%20mvc'
        User.all.each do |u|
          page.should_not have_link(u.name, href: user_path(u))
        end
      end
    end
  end
  describe "index" do
    let(:user) {FactoryGirl.create(:user)}
    before(:each) do
      sign_in user
      visit users_path
    end
    it {should have_selector('title', text: 'Nivter Users')}
    describe "pagination" do
      before(:all) {30.times {FactoryGirl.create(:user)}}
      after(:all) {User.delete_all}
      it {should have_selector('div.pagination')}
      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
    describe "delete links" do
      it {should_not have_link('delete')}
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end
  describe "following/followers" do
    let(:user) {FactoryGirl.create(:user)}
    let(:followed) {FactoryGirl.create(:user)}
    before {user.follow!(followed)}
    describe "following" do
      before do
        sign_in user
        visit following_user_path(user)
      end
      it { should have_selector('title', text: full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it {should have_link(followed.name, href: user_path(followed))}
    end
    describe "followers" do
      before do
        sign_in followed
        visit followers_user_path(followed)
      end
      it { should have_selector('title', text: full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it {should have_link(user.name, href: user_path(user))}
    end
  end
end