FactoryGirl.define do
	factory :user do
		sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
		password "foobar"
		password_confirmation "foobar"
		experience "msmq mvc"
		interested_in "nancyfx fubumvc"
		country "France"
		city "Lille"
		
		factory :admin do
			admin true
		end
	end
	factory :micropost do
		content 'lorem ipsom'
		user
	end
end