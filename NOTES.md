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


# Managing Nova services and instances

## Fixing instances in `error` status

1.  SSH to `mc.cb-1-1.morphcloud.net`

        ssh -p 2222 <<your username>>@mc.cb-1-1.morphlabs.net

    If it asks for a password and says `Permission denied`, your SSH key
    needs to be added to the users list on the server.

2.  Execute `.novarc` to set nova credentials. If `.novarc` is not
    available, run the following commands instead:

    export OS_TENANT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=klnm12
    export OS_AUTH_URL=http://127.0.0.1:5000/v2.0

3.  List all instances

        $ nova list --all
        +--------------------------------------+---------------------+---------+----------------------------------+
        |                  ID                  |         Name        |  Status |             Networks             |
        +--------------------------------------+---------------------+---------+----------------------------------+
        | 104ae838-864f-4067-98f9-58efa8b3a58a | Dewayne Wolff       | SHUTOFF |                                  |
        | 13ee6ff1-9e9b-497f-8ee0-b149d9768621 | Christa Mayert MD   | ACTIVE  | private=10.1.0.80                |
        | 14798024-c774-461b-894c-fe2cf05837e3 | Emilio Emmerich Sr. | ERROR   |                                  |
        | 4697742b-91f0-4a74-a2c3-ee95ecb80ae4 | Ms. Rowena Jerde    | ACTIVE  | private=10.1.0.98                |
        | 5f98bb5c-b914-46b5-8563-2c3b95a6488b | Ona Yundt           | ACTIVE  | private=10.1.0.74                |
        | 83dc527c-a47c-4037-ae91-ce18c5d6f461 | Dr. Edison Reichel  | ACTIVE  | private=10.1.0.91                |
        | 8fbd3c08-06f3-421c-99ab-5c24e2d06767 | Noemi Zieme         | ACTIVE  | private=10.1.0.105               |
        | c6d2c5a4-9b6a-4ccc-a4db-305efd17d5b2 | Instance takeka     | ACTIVE  | private=10.1.0.78, 10.50.255.237 |
        | d99dc65a-98ad-4227-9d85-0c2b3192b67f | Casey Schoen        | ACTIVE  | private=10.1.0.88                |
        +--------------------------------------+---------------------+---------+----------------------------------+

4. SSH to cn25

        ssh cn25

5. List all instances.

        $ virsh list --all
        Id Name                 State
        ----------------------------------
        - instance-00000884    shut off
        - instance-0000088b    shut off
        - instance-00000890    shut off
        - instance-00000899    shut off
        - instance-000008b0    shut off
        - instance-000008b2    shut off
        - instance-000008b6    shut off

6.  Double check for running instance.

        $ list=`virsh list --all|grep running | awk '{print $2}'`

7.  Display inside list variable.

        $ echo $list
        instance-00000884 instance-0000088b instance-00000890 instance-00000899 instance-000008b0 instance-000008b2 instance-000008b6

8.  Change instance status to undefined.

        $ for i in $list; do virsh undefine $i; done
        Domain instance-00000884 has been undefined

        Domain instance-0000088b has been undefined

        Domain instance-00000890 has been undefined

        Domain instance-00000899 has been undefined

        Domain instance-000008b0 has been undefined

        Domain instance-000008b2 has been undefined

        Domain instance-000008b6 has been undefined

9.  Check for the instances having a state equals Shut Off

        $ virsh list --all
        Id Name                 State
        ----------------------------------

10. Exit cn25 (`exit` or `<Ctrl + D>`)

11. Login to PostgreSQL

        psql nova nova -W -h 172.16.1.1

12. Update instance status.

        nova=> update instances set deleted ='t' , deleted_at = now() where deleted ='f';
        UPDATE 9
        nova=> \q or < Ctrl + D >

13. List all Nova services

        $ nova-manage service list
        Binary           Host                                 Zone             Status     State Updated_At
        nova-compute     cn25.cb-1-1.morphcloud.net           nova             enabled    XXX   2012-06-04 19:19:50.352503
        nova-scheduler   mc.cb-1-1.morphcloud.net             nova             enabled    XXX   2012-06-04 19:19:57.212497
        nova-volume      mc.cb-1-1.morphcloud.net             nova             enabled    XXX   2012-06-04 19:19:58.613001
        nova-network     cn25.cb-1-1.morphcloud.net           nova             enabled    XXX   2012-06-04 19:20:02.073767
        nova-consoleauth mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:14:34.437769
        nova-console     mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:14:35.887631

    __NOTE__: Check for the state `XXX`

14. Check the status of the Nova services

        $ status nova-volume
        nova-volume stop/waiting

15. Start the Nova services that are not running

        $ start nova-scheduler
        nova-scheduler start/running, process 9858

16. Check Nova Services:

        $ nova-manage service list
        Binary           Host                                 Zone             Status     State Updated_At
        nova-console     mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:47.001293
        nova-scheduler   mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:48.138922
        nova-compute     cn25.cb-1-1.morphcloud.net           nova             enabled    :-)   2012-06-05 01:19:52.098674
        nova-network     cn25.cb-1-1.morphcloud.net           nova             enabled    :-)   2012-06-05 01:19:52.298518
        nova-volume      mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:55.237728
        nova-consoleauth mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:55.309350

    __NOTE__: You should all be good if you will not see state `XXX`

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
