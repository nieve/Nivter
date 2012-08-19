require 'spec_helper'

describe "StaticPages" do
  describe "home page" do
    it "should have the content nivter" do
      visit '/static_pages/home'
      page.should have_content('nivter')
    end
    it "should have the title home" do
      visit '/static_pages/home'
      page.should have_selector('title', :text => 'Nivter | Home')
    end
  end
  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      page.should have_content('Help')
    end
    it "should have the title help" do
      visit '/static_pages/help'
      page.should have_selector('title', :text => 'Nivter | Help')
    end
  end
  describe "About page" do
  	it "should have the content 'About Us" do
  	  visit '/static_pages/about'
  	  page.should have_content('About Us')
  	end
    it "should have the title about us" do
      visit '/static_pages/about'
      page.should have_selector('title', :text => 'Nivter | About')
    end
  end
end
