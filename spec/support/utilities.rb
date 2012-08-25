def full_title(title)
	base_title = "Nivter"
	if title.empty?
		base_title
	else
		"#{base_title} | #{title}"
	end
end