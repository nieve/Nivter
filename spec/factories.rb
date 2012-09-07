FactoryGirl.define do
	factory :user do
		name 'ozu'
		email 'n@g.test'
		password 'foobar'
		password_confirmation 'foobar'
	end
end