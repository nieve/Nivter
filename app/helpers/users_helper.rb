module UsersHelper
	# Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, params=nil)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    qs = params != nil ? "?s=#{params[:size]}" : "";
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}#{qs}"
	  image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
