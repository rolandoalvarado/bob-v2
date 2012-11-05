def bob_password
  '123qwe'
end

def member_password
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

def admin_role?(role)
  !!role.match(/project[ _]manager|system[ _]admin/i)
end
