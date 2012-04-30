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
      { DB_NAME => 'projectmanager', FRIENDLY_NAME => 'Project Manager' },
      { DB_NAME => 'admin',          FRIENDLY_NAME => 'Cloud Admin'     },
      { DB_NAME => 'itsec',          FRIENDLY_NAME => 'IT Security'     },
      { DB_NAME => 'netadmin',       FRIENDLY_NAME => 'Network Admin'   },
      { DB_NAME => 'projectmanager', FRIENDLY_NAME => 'Project Manager' },
      { DB_NAME => 'Member',         FRIENDLY_NAME => 'Member'          }
    ]
  end
end