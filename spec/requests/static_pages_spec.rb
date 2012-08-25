require 'spec_helper'

describe "StaticPages" do
  subject {page}
  describe "home page" do
    before {visit root_path}
    it {page.should have_selector('h1', :text=> 'nivter')}
    it {page.should_not have_selector('title', :text=> 'Home')}
    it {page.should have_selector('title', :text => full_title(''))}
  end
  describe "Help page" do
    before {visit help_path}
    it {page.should have_content('Help')}
    it {page.should have_selector('title', :text => full_title('Help'))}
  end
  describe "About page" do
    before {visit about_path}
  	it {page.should have_content('About Us')}
    it {page.should have_selector('title', :text => full_title('About'))}
  end
  describe "Contact" do
    before {visit contact_path}
    it {page.should have_selector('title', :text => full_title('Contact'))}
    it {page.should have_selector('h1', :text => 'Contact Us')}
  end
end
