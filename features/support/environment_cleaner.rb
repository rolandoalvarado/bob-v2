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

  def register(object_type, object_id)
    object_types = [USER, PROJECT]

    if object_types.include?(object_type)
      registry[object_type] ||= []
      registry[object_type] << object_id
    else
      raise "Unknown cloud object type #{ object_type }. Recognized types are " +
            "#{ object_types.join(', ') }."
    end
  end

  def delete_test_objects
    puts "Deleting test objects (Cancel with Ctrl-C)" if registry.count > 0
    delete_test_users
    delete_test_projects
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

      puts "    Deleting instances..."
      deleted_instances = @compute_service.delete_instances_in_project(project)
      deleted_instances.each do |instance|
        puts "      DELETED: #{ instance[:name] } (id: #{ instance[:id] })"
      end

      puts "    Deleting volumes..."
      deleted_volumes = @volume_service.delete_volumes_in_project(project)
      deleted_volumes.each do |volume|
        puts "      DELETED: #{ volume[:name] } (id: #{ volume[:id] })"
      end

      puts "    Deleting #{ project.name }..."
      @identity_service.delete_project(project)
    end
  rescue Exception => e
    puts "\033[0;33m  WARNING: 1 or more projects could not be deleted. The error returned was: " +
         e.inspect + "\033[m"
  end

  def delete_test_users
    user_ids = registry[USER]
    return unless user_ids

    puts "Deleting test users and their memberships..."

    user_ids.uniq.each do |user_id|
      user = @identity_service.users.reload.find { |u| u.id == user_id }
      next if user.nil? || user.name == 'admin'

      puts "  #{ user.name }..."
      @identity_service.delete_user(user)
    end
  rescue Exception => e
    puts "\033[0;33m  WARNING: 1 or more users could not be deleted. The error returned was: " +
         e.inspect + "\033[m"
  end

end