require 'spec_helper'

describe "StaticPages" do
  subject {page}
  shared_examples_for "all static pages" do
    it {page.should have_selector('h1', :text=> heading)}
    it {page.should have_selector('title', :text => full_title(page_title))}
  end
  describe "home page" do
    before {visit root_path}
    let (:heading){'nivter'}
    let (:page_title){''}
    it_should_behave_like "all static pages"
    it {page.should_not have_selector('title', :text=> 'Home')}
    describe "when user signed in" do
      let(:user){FactoryGirl.create(:user)}
      before do 
        FactoryGirl.create(:micropost, user: user, content: 'stabat matter')
        FactoryGirl.create(:micropost, user: user, content: 'de la rosa')
        sign_in user
        visit root_path
      end
      it "should show the feed" do
        page.should have_selector('li', :text => 'stabat matter')
        page.should have_selector('li', :text => 'de la rosa')
      end
      describe "followers/following counts" do
        let(:other_user) {FactoryGirl.create(:user)}
        before do
          user.follow!(other_user)
          visit root_path
        end
        it {should have_link('1 following', herf: following_user_path(user))}
        it {should have_link('0 followers', herf: followers_user_path(user))}
      end
    end
  end
  describe "Help page" do
    before {visit help_path}
    let (:heading){'Help'}
    let (:page_title){'Help'}
    it_should_behave_like "all static pages"
  end
  describe "About page" do
    before {visit about_path}
    let (:heading){'About Us'}
    let (:page_title){'About'}
    it_should_behave_like "all static pages"
  end
  describe "Contact" do
    before {visit contact_path}
    let (:heading){'Contact Us'}
    let (:page_title){'Contact'}
    it_should_behave_like "all static pages"
  end
end
