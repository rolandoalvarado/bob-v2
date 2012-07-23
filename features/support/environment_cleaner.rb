# EnvironmentCleaner class
# ------------------------
# Deletes all objects created during the tests. Objects must be registered
# via EnvironmentCleaner::register for them to be deleted.
#
# To initiate the cleanup, EnvironmentCleaner::delete_test_objects should be
# called within an `at_exit` hook (See features/support/hooks.rb)

require 'singleton'
require 'anticipate'

class EnvironmentCleaner
  include Anticipate
  include Singleton

  # Use constants so that we can detect typos at 'compile' time
  USER    = :user
  PROJECT = :project

  attr_accessor :registry

  #============================
  # CLASS METHODS
  #============================

  def self.register(object_type, object_id)
    instance.register object_type, object_id
  end

  def self.delete_test_objects
    instance.delete_test_objects
  end

  #============================
  # INSTANCE METHODS
  #============================

  def initialize
    @registry = {}
    @identity_service = IdentityService.session
    @compute_service  = ComputeService.session
    @volume_service   = VolumeService.session
  end

  def register(object_type, options)
    object_types = [USER, PROJECT]

    if object_types.include?(object_type)
      registry[object_type] ||= []
      registry[object_type] << options unless registry[object_type].include?(options)
    else
      raise "Unknown cloud object type #{ object_type }. Recognized types are " +
            "#{ object_types.join(', ') }."
    end
  end

  def delete_test_objects
    puts "Deleting test objects (Cancel with Ctrl-C)" if registry.count > 0
    delete_test_projects
    delete_test_users
  end


  #============================
  # PRIVATE METHODS
  #============================

  private

  def delete_test_projects
    project_ids = registry[PROJECT]
    return unless project_ids

    puts "Deleting test projects and their resources..."

    project_ids.uniq.each do |project_id|
      project = @identity_service.tenants.reload.find { |t| t.id == project_id }
      next if project.nil? || project.name == 'admin'
      puts "  #{ project.name }..."

      begin
        @compute_service.set_tenant project
        @volume_service.set_tenant project

        if @compute_service.addresses.count > 0
          puts "    Releasing addresses..."
          released_addresses = @compute_service.release_addresses_from_project(project)
          released_addresses.each do |address|
            puts "     RELEASED: #{ address[:ip] } (id: #{ address[:id] })"
          end
        end

        if @compute_service.instances.count > 0
          puts "    Deleting instances..."
          # Needed when an instance is doing hard reboot. 
          # Wait until an instance become in active state.
          sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
            deleted_instances = @compute_service.delete_instances_in_project(project)
            deleted_instances.each do |instance|
              puts "      DELETED: #{ instance[:name] } (id: #{ instance[:id] })"
            end
          end
        end

        if @volume_service.snapshots.count > 0
          puts "    Deleting volume snapshots..."
          deleted_volume_snapshots = @volume_service.delete_volume_snapshots_in_project(project)
          deleted_volume_snapshots.each do |snapshot|
            puts "      DELETED: #{ snapshot[:name] } (id: #{ snapshot[:id] })"
          end
        end

        if @volume_service.volumes.count > 0
          puts "    Deleting volumes..."
          deleted_volumes = @volume_service.delete_volumes_in_project(project)
          deleted_volumes.each do |volume|
            puts "      DELETED: #{ volume[:name] } (id: #{ volume[:id] })"
          end
        end

        if project.users.reload.count > 0
          puts "    Revoking memberships..."
          project.users.reload.each do |user|
            next if user.name == "admin"
            @identity_service.revoke_all_user_roles(user, project)
            puts "     REVOKED: #{ user.name } (id: #{ user.id })"
          end
        end

        puts "    Deleting #{ project.name }..."
        sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
          @identity_service.delete_project(project)
        end
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ project.name } could not be deleted. The error returned was: " +
             e.inspect + "\033[m"
      end
    end
  end

  def delete_test_users
    user_ids = registry[USER]
    return unless user_ids

    puts "Deleting test users and their memberships..."

    user_ids.uniq.each do |user_id|
      if user_id.class == String || (user_id.class == Hash && user_id[:id])
        user = @identity_service.users.reload.find { |u| u.id == user_id }
      elsif user_id.class == Hash && user_id[:name]
        user = @identity_service.users.reload.find { |u| u.name == user_id[:name] }
      else
        puts puts "\033[0;33m  WARNING: Unknown user identifier #{ user_id.inspect } \033[m"
        next
      end
      next if user.nil? || user.name == 'admin'
      puts "  #{ user.name }..."

      begin
        @identity_service.delete_user(user)
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ user.name } could not be deleted. The error returned was: " +
             e.inspect + "\033[m"
      end
    end
  end

end
