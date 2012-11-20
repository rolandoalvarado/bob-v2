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
                  format_failure(name, { id: id }, 'failed', 2)
                else
                  format_success(name, { id: id }, 'deleted', 2)
                end
              end
            end
          end
        end
      end
    rescue Net::SSH::AuthenticationFailed => e
      puts "\033[0;33m  Could not connect to #{ username }@#{ host }. The error returned was: " +
           e.message + "\033[m"
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

      retried = false
      begin
        @image_service.delete_image(image)
        format_success(image.name, { id: image.id }, 'deleted', 2)
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ image.name } could not be deleted. The error returned was: " +
             e.message + "\033[m"
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
      format_header project.name, '', 0

      success = false
      retried = false
      error = ''
      begin
        @compute_service.set_tenant! project
        @volume_service.set_tenant! project

        if @compute_service.addresses.count > 0
          format_header 'addresses', 'releasing'
          released_addresses = @compute_service.release_addresses_from_project(project)
          released_addresses.each do |address|
            format_success address[:ip], address.slice(:id, :instance_id), 'released'
          end
        end

        if @compute_service.service.servers.count > 0
          format_header 'instances'
          deleted_instances = @compute_service.delete_instances_in_project(project)

          deleted_instances.each do |instance|
            format_success instance.delete(:name), instance
          end
        end

        # Clean-up Images in Glance
        #if @image_service.get_glance_images.count > 0
          #format_header 'images [glance]'
          #deleted_images = @image_service.delete_images(project)

          #deleted_images.each do |deleted_image|
            #format_success deleted_image.delete(:name), deleted_image
          #end
        #end

        # Clean-up Instance Snapshots in Nova
        if @compute_service.get_nova_images(project).count > 0
          format_header 'instance snapshots [nova]'
          deleted_instance_snapshots = @compute_service.delete_instance_snapshots(project)

          deleted_instance_snapshots.each do |snapshot|
            format_success snapshot.delete(:name), snapshot
          end
        end

        if @volume_service.snapshots.count > 0
          format_header 'volume snapshots'
          deleted_volume_snapshots = @volume_service.delete_volume_snapshots_in_project(project)
          deleted_volume_snapshots.each do |snapshot|
            format_success snapshot.delete(:name), snapshot
          end
        end

        if @volume_service.volumes.count > 0
          format_header 'volumes'
          deleted_volumes = @volume_service.delete_volumes_in_project(project)
          deleted_volumes.each do |volume|
            format_success volume.delete(:name), volume
          end
        end

        users = project.users.reload
        if users.count > 0
          format_header 'memberships', 'revoking'
          users.each do |user|
            next if user.name == "admin"
            @identity_service.revoke_all_user_roles(user, project)
            format_success user.name, id: user.id
          end
        end

        @identity_service.delete_project(project)
        format_success(project.name, { id: project.id }, 'deleted', 2)
        success = true
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ project.name } could not be deleted. The error returned was: " +
             e.message + "\033[m"
        unless retried
          retried = true
          sleep(ConfigFile.wait_short)
          puts "\033[0;33mRetrying...\033[m"
          retry
        end
        error = e.message
      ensure
        unless success
          failed_at = Time.now
          project.update(name: "failed delete #{ failed_at.strftime('%Y%m%d%H%M%S') }",
                         description: "Delete #{ project.name } failed #{ failed_at }. #{ error }") rescue nil
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
      format_header user.name, '', 0

      retried = false
      begin
        @identity_service.delete_user(user)
        format_success(user.name, { id: user.id }, 'deleted', 2)
      rescue Exception => e
        puts "\033[0;33m  ERROR: #{ user.name } could not be deleted. The error returned was: " +
             e.message + "\033[m"
        unless retried
          retried = true
          sleep(ConfigFile.wait_short)
          puts "\033[0;33mRetrying...\033[m"
          retry
        end
      end
    end
  end

  def format_header(items, action = 'deleting', indent = 2)
    puts "\033[0;36m#{ ' ' * indent }#{ action.capitalize } \033[1;36m#{ items }\033[0;36m...\033[m"
  end

  def format_success(item, properties = {}, action='deleted', indent = 4)
    print "\033[0;32m#{ ' ' * indent }#{ action.upcase }: \033[1;32m#{ item }\033[0;32m"
    unless properties.empty?
      print " ("
      print properties.map { |k, v| "#{ k }: #{ v }" }.join(', ')
      print ")"
    end
    print "\033[m\n"
  end

  def format_failure(item, properties = {}, action='failed', indent = 4)
    print "\033[0;12m#{ ' ' * indent }#{ action.upcase }: \033[1;12m#{ item }\033[0;12m"
    unless properties.empty?
      print " ("
      print properties.map { |k, v| "#{ k }: #{ v }" }.join(', ')
      print ")"
    end
    print "\033[m\n"
  end

end
