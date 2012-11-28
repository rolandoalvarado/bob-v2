def bob_password
  '123qwe'
end

def member_password
  '123qwe'
end

def other_password
  '123qwe'
end

def bob_username
  Unique.username('bob')
end

def bob_logout_username
  Unique.username('bob-logout')
end

def bob_redirect_username
  Unique.username('bob-redirect')
end

def member_username
  Unique.username('member')
end

def other_username
  Unique.username('other')
end

def existing_username
  Unique.username('existing')
end

def admin_role?(role)
  !!role.match(/project[ _]manager|system[ _]admin/i)
end

def bob_email
  'bob@example.com'
end

def other_email
  'other@example.com'
end
