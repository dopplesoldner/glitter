def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

# Returns the Gravatar (http://gravatar.com/) for the given user.
def gravatar_for(user)
  gravatar_id = Digest::MD5::hexdigest(user.email)
  gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
  image_tag(gravatar_url, alt: user.name, class: "gravatar")
end

#sign in helper
def sign_in(user)
  visit signin_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end