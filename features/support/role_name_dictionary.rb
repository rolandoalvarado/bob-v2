module RoleNameDictionary
  DB_NAME       = :db_name
  FRIENDLY_NAME = :friendly_name

  def self.db_name(friendly_name)
    role = roles.find{ |r| r[FRIENDLY_NAME] == friendly_name }
    role[DB_NAME] if role
  end

  def self.friendly_name(db_name)
    raise_if_missing_key(DB_NAME)
    role = roles.find{ |r| r[DB_NAME] == db_name }
    role[FRIENDLY_NAME] if role
  end

  def self.roles
    [
      { DB_NAME => 'admin',          FRIENDLY_NAME => 'Project Manager'      },
      { DB_NAME => 'admin',          FRIENDLY_NAME => 'System Administrator' },
      { DB_NAME => 'Member',         FRIENDLY_NAME => 'Member'               }
    ]
  end
end