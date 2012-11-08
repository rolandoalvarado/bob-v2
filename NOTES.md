# Working on your local copy of Bob

Add https://github.com/MorphGlobal/bob to your remote repos and nickname it as 'upstream'

    git remote add upstream git@github.com:MorphGlobal/bob.git

Create a topic branch where you will commit your local work

    git checkout master
    git checkout -b topic_branch_name_here

Get the latest changes from upstream

    git fetch upstream

After the above command is done, all upstream/* branches should have the latest commits. You can see all upstream/* branches by running the following command:

    git branch -r

To merge upstream/master to your local master branch

    git checkout master
    git merge upstream/master

To sync your topic branch with your local master branch

    git checkout topic_branch_name_here
    git merge master

To push your topic branch to your remote repo

    git push origin topic_branch_name_here

After the above, you can then send a pull request to MorphGlobal. Set the source branch to your topic branch's name and set the target branch to MorphGlobal/master

# Test Fog via console

    bundle console
    irb > require File.expand_path('features/support/cloud_configuration.rb')
    irb > image_service    = Fog::Image.new(ConfigFile.cloud_credentials)
    irb > compute_service  = Fog::Compute.new(ConfigFile.cloud_credentials)
    irb > identity_service = Fog::Identity.new(ConfigFile.cloud_credentials)
    irb > volume_service   = Fog::Volume.new(ConfigFile.cloud_credentials)

You should now be able to interact with the OpenStack services in the target mCloud environment.

# Testing CSS and XPath selectors using the Nokogiri gem

Inspect the page, then, in the inspector, right-click on the html element and
click Copy as HTML. Paste to the file /tmp/bob.html

    bundle console
    html = Nokogiri::HTML.parse(File.open("/tmp/bob.html"))

The `html` variable now points to a `Nokogiri::HTML::Document` object that you can
play around with. For example, assuming your html string contains an element
`<span class='label'>Here is my label</span>`:

    html.css(".label").count

The above will return a value of 1.

    html.css(".label").content

The above will return `Here is my label`

More info about the Nokogiri gem and its methods at [http://nokogiri.org/](http://nokogiri.org/).
## ------------------------------------------------------------------------------
## Steps in Cleaning-up La-1-9 Instances
## IMPORTANT: 
    - la-1-9 mc is mn.
    - when vm overflow occur, you have to delete vms on mc.

1. Login to `mc.la-1-9.morphlabs.net` via SSH.
  
  - terminal:~$ ssh ralvarado@mc.la-1-9.morphlabs.net
  
2. Execute `sudo su -` to become root user.
  - $ sudo su -
  
3. Execute `. .novaenv` to initialize nova environment variables.   
  - root@mc.la-1-9:~# . .novaenv
  
4. Check instance status
  - root@mc.la-1-9:~# nova list --all
  
  NOTE: Look for running, error and shut off instances status
  
5. Change user to `nova` to access CN43
  - root@mc.la-1-9:~# su - nova
  
6. Login to CN43 using ip address `172.16.9.43`
  - nova@mc:~$ ssh 172.16.9.43
7. Check for instance status again right now in `CN43`
  - nova@cn43:~$ virsh list --all

8. Execute `sudo su -` to become `root` user.
  - nova@cn43:~$ sudo su -

  NOTE: You should be root user to destroy or update instance state in CN
  
9. First Destroy `running` instances
  A. Store instances with running state in a list.
    - root@cn43.la-1-9:~# list=`virsh list --all|grep running | awk '{print $2}'`

  B. Execute for loop and destroy, update state to `undefine`.
    - root@cn43.la-1-9:~# for i in $list; do  virsh destroy $i;  virsh undefine $i; done       
    
  C. Check if `running` instances are gone.
    - root@cn43.la-1-9:~# virsh list --all
    
10. Second Destroy `shut off` intances 
  A. Store instances with shut off state in a list.
    - root@cn43.la-1-9:~# list=`virsh list --all|grep 'shut off' | awk '{print $2}'`

  B. Update state to `undefine`.
    - root@cn43.la-1-9:~# for i in $list; do  virsh undefine $i; done
                          
  C. Check if `shut off` instances are gone.
    - root@cn43.la-1-9:~# virsh list --all                        

  NOTE: If you will still see instances when executing virsh list --all. 
        Exit from CN43 to refresh and login then check again the instances.
        
11. Exit from CN43
    - root@cn43.la-1-9:~# exit
    - nova@cn43:~$ exit
    
12. Login to `nova` database
    - nova@mc:~$ psql nova nova -W -h 172.16.9.1

13. Update instances in nova database.
    - nova=> update instances set deleted ='t' , deleted_at = now() where deleted ='f';
      
      RESULT: UPDATE XX
      
    - nova=> \q or < Ctrl + D >
    
# How to clean snapshots using nova command.
1. Store snaphots with specified `name` in a list
    - root@mc.la-1-9:~# list=`nova image-list | grep 'test-snapshot R' | awk '{print $2}'`
  
2. Delete image using image_id
    - root@mc.la-1-9:~# for i in $list; do nova image-delete $i; done
    
## -----------------------------------------------------------------------------      
## Resetting instances when encountering failed to start instance

1.  Reset db (in mc)

        $ psql nova nova -W -h 172.16.1.1
        nova=> update instances set deleted ='t' , deleted_at = now() where deleted ='f';
        UPDATE XXX
        nova=> <ctrl+D>

2.  Reset vms (in cn)

        $ ssh cn25
        Warning: Permanently added 'cn25' (ECDSA) to the list of known hosts.
        root@cn25's password: <<please enter root password>>

        $ list=`virsh list --all|grep running | awk '{print $2}'`
        $ for i in $list; do virsh destroy $i; done
        $ list=`virsh list --all|grep shut| awk '{print $2}'`
        $ for i in $list; do virsh undefine $i; done

# Connecting to nexenta server (volume server)

1.  Create port forwarding connection

        ssh -p 2222 root@mc.cb-1-1.morphcloud.net -L 2000:172.16.255.27:2000

2.  Access the URL using the browser

        http://localhost:2000
        username nova-cb-1-1
        password klnm12

The nexenta connection information is in `/etc/nova/nova.conf`.

# Connecting to Fog

Move to bob directory and execute them.

    cd `bundle show fog`
    bundle install
    bundle exec irb

If you get an error that requires packages, please execute

    bundle install

In irb, you can call Fog library like this.

    irb > load './.irbrc'
    irb > connect('admin', 'klnm12','<<tenant name>>','http://mc.cb-1-1.morphcloud.net:35357/')
    irb > connection[:compute].volumes

# Using Chrome as test browser

In Mac, use homebrew.
    brew install chromedriver

For Linux, download chromedriver from here:
http://code.google.com/p/chromedriver/downloads/list. Extract the file and copy to `/usr/local/bin` directory and set the permission to `755`. Then set `:chrome: true` in `config.yml`.

# Configuring Jenkins for Bob

The _Execute Shell_ build script should be configured as the following:

    #!/bin/bash

    export TARGET=<<host>>

    export WEB_CLIENT_HOST=https://$TARGET
    export WEB_CLIENT_USER=admin
    export WEB_CLIENT_API_KEY=klnm12
    export WEB_CLIENT_TENANT=admin
    export CAPYBARA_DRIVER=selenium

    #run/setup
    run/configurator --no-tunnel -h $WEB_CLIENT_HOST -o
    http://$TARGET:35357/v2.0/tokens -u $WEB_CLIENT_USER -p
    $WEB_CLIENT_API_KEY -t $WEB_CLIENT_TENANT -d $CAPYBARA_DRIVER

    run/verifier ci <<tag/s>>

__NOTE__: Use `run/configurator` instead of `run/setup` to skip
installing dependencies.

