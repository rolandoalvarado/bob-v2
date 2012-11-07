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
  IMAGE   = :image

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

  def self.delete_orphans
    instance.delete_orphans
  end

  #============================
  # INSTANCE METHODS
  #============================

  def initialize
    @registry = {}
  end

  def register(object_type, options)
    object_types = [USER, PROJECT, IMAGE]

    if object_types.include?(object_type)
      registry[object_type] ||= []
      registry[object_type] << options unless registry[object_type].include?(options)
    else
      raise "Unknown cloud object type #{ object_type }. Recognized types are " +
            "#{ object_types.join(', ') }."
    end
  end

  def delete_test_objects
    if registry.count > 0
      puts "Deleting test objects (Cancel with Ctrl-C)"
      IdentityService.session.reset_credentials
      ComputeService.session.reset_credentials
      VolumeService.session.reset_credentials
      delete_test_projects
      delete_test_users
    else
      puts "No test objects to delete."
    end
  end

  def delete_orphans
    return unless ConfigFile.server_username
    @identity_service ||= IdentityService.session
    orphaned_count = 0
    puts "Deleting orphaned resources (Cancel with Ctrl-C)"
    IdentityService.session.reset_credentials
    exempted_tenants = %w{ admin demo }
    tenant_ids = @identity_service.tenants.reload.select { |t| exempted_tenants.include?(t.name) }.collect(&:id)

    nova_options = { os_tenant_name: ConfigFile.admin_tenant,
                     os_username: ConfigFile.admin_username,
                     os_password: ConfigFile.admin_api_key,
                     os_auth_url: 'http://127.0.0.1:5000/v2.0' }.map { |key, value| "--#{ key } #{ value }" }.join(' ')
    host = URI.parse(ConfigFile.web_client_url).host
    username = ConfigFile.server_username || `whoami`.chomp

    begin
      Net::SSH.start(host, username, port: 2222, timeout: 30) do |ssh|
        table = ssh.exec!(%{ nova #{ nova_options } list --all | grep -G "^|" | tail -n +2 })
        table.to_s.tr('|', ' ').each_line do |row|
          id, name, status = row.split
          if tenant_info = ssh.exec!(%{ sudo nova #{ nova_options } show #{ id } | grep -G "^| tenant_id" })
            tenant_id = tenant_info.tr('|', ' ').split.last
            if !tenant_ids.include?(tenant_id) && status.to_s =~ /ACTIVE|ERROR|STATUS/
              orphaned_count += 1
              ssh.exec!("sudo nova #{ nova_options } delete #{ id }") do |ch, stream, data|
                if stream == :stderr
                  puts "       FAILED: #{ name } (id: #{ id })"
                else
                  puts "      DELETED: #{ name } (id: #{ id })"
                end
              end
            end
          end
        end
      end
    rescue Net::SSH::AuthenticationFailed => e
      puts "\033[0;33m  Could not connect to #{ username }@#{ host }. The error returned was: " +
           e.inspect + "\033[m"
    end
    puts "No orphaned resources found" if orphaned_count == 0
  end


  #============================
  # PRIVATE METHODS
  #============================

  private

  def delete_test_images
    image_ids = registry[IMAGE]
    return unless image_ids

    puts "Deleting test images..."
    @image_service ||= ImageService.session

    image_ids.uniq.each do |image_id|
      image = @image_service.images.reload.find { |i| i.id == image_id }
      next if image.nil?
      puts "  #{ image.name }..."

      retried = false
      begin
        @image_service.delete_image(image)
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ image.name } could not be deleted. The error returned was: " +
             e.inspect + "\033[m"
        unless retried
          retried = true
          sleep(ConfigFile.wait_short)
          puts "Restarting deleting test images..."
          retry
        end
      end
    end
  end

  def delete_test_projects
    project_ids = registry[PROJECT]
    return unless project_ids

    puts "Deleting test projects and their resources..."
    @identity_service = IdentityService.session
    @compute_service  = ComputeService.session
    @volume_service   = VolumeService.session
    @image_service    = ImageService.session

    project_ids.uniq.each do |project_id|
      project = @identity_service.tenants.reload.find { |t| t.id == project_id }
      next if project.nil? || project.name == 'admin'
      puts "  #{ project.name }..."

      success = false
      retried = false
      begin
        @compute_service.set_tenant project
        @volume_service.set_tenant project

        if @compute_service.addresses.count > 0
          puts "    Releasing addresses..."
          released_addresses = @compute_service.release_addresses_from_project(project)
          released_addresses.each do |address|
            puts "     RELEASED: #{ address[:ip] } (id: #{ address[:id] }, instance_id: #{ address[:instance_id] || '-' })"
          end
        end

        if @compute_service.instances.count > 0
          puts "    Deleting instances..."
          deleted_instances = @compute_service.delete_instances_in_project(project)

          deleted_instances.each do |instance|
            puts "      DELETED: #{ instance[:name] } (id: #{ instance[:id] })"
          end
        end

        # Clean-up Instance Snapshots
        if @image_service.get_instance_snapshots.count > 0
          puts "    Deleting instance snapshots..."
          deleted_instance_snapshots = @image_service.delete_instance_snapshots(project)

          deleted_instance_snapshots.each do |snapshot|
            puts "      DELETED: #{ snapshot[:name] } (id: #{ snapshot[:id] })"
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

        users = project.users.reload
        if users.count > 0
          puts "    Revoking memberships..."
          users.each do |user|
            next if user.name == "admin"
            @identity_service.revoke_all_user_roles(user, project)
            puts "      REVOKED: #{ user.name } (id: #{ user.id })"
          end
        end

        puts "    Deleting #{ project.name } (id: #{ project.id })..."
        @identity_service.delete_project(project)
        success = true
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ project.name } could not be deleted. The error returned was: " +
             e.inspect + "\033[m"
        unless retried
          retried = true
          sleep(ConfigFile.wait_short)
          puts "Restarting deleting test projects and their resources..."
          retry
        end
      ensure
        unless success
          failed_at = Time.now
          project.update(name: "failed delete #{ failed_at.strftime('%Y%m%d%H%M%S') }",
                         description: "Failed to delete #{ project.name } on #{ failed_at }. #{ project.description }") rescue nil
        end
      end
    end
  end

  def delete_test_users
    user_ids = registry[USER]
    return unless user_ids

    puts "Deleting test users and their memberships..."
    @identity_service = IdentityService.session

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

      retried = false
      begin
        @identity_service.delete_user(user)
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ user.name } could not be deleted. The error returned was: " +
             e.inspect + "\033[m"
        unless retried
          retried = true
          sleep(ConfigFile.wait_short)
          puts "Restarting deleting test users and their memberships..."
          retry
        end
      end
    end
  end

  def say_with_time(message, &block)
    start_time = Time.now
    puts "    #{ message }... (started #{ start_time })"
    yield
    end_time = Time.now
    puts "        (finished in #{ end_time - start_time } at #{ end_time })"
  end

end
