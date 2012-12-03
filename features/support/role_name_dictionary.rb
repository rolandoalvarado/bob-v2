module RoleNameDictionary
  DB_NAME       = :db_name
  FRIENDLY_NAME = :friendly_name

  def self.roles
    [
      { DB_NAME => 'project_manager', FRIENDLY_NAME => 'Project Manager' },
      { DB_NAME => 'admin',           FRIENDLY_NAME => 'System Admin'    },
      { DB_NAME => 'admin',           FRIENDLY_NAME => 'Admin'           },
      { DB_NAME => 'Member',          FRIENDLY_NAME => 'Member'          }
    ]
  end

  def self.db_name(friendly_name)
    role = roles.find{ |r| r[FRIENDLY_NAME] == friendly_name }
    raise "The '#{ friendly_name }' role couldn't be found. Check that it's " +
          "declared in #{ File.expand_path(__FILE__) }" unless role
    role[DB_NAME]
  end

  def self.friendly_name(db_name)
    raise_if_missing_key(DB_NAME)
    role = roles.find{ |r| r[DB_NAME] == db_name }
    raise "The '#{ db_name }' role couldn't be found. Check that it's " +
          "declared in #{ File.expand_path(__FILE__) }" unless role
    role[FRIENDLY_NAME]
  end
end
