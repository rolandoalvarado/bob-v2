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

```
bundle console
irb > require File.expand_path('features/support/cloud_configuration.rb')
irb > image_service    = Fog::Image.new(ConfigFile.cloud_credentials)
irb > compute_service  = Fog::Compute.new(ConfigFile.cloud_credentials)
irb > identity_service = Fog::Identity.new(ConfigFile.cloud_credentials)
irb > volume_service   = Fog::Volume.new(ConfigFile.cloud_credentials)
```
You should now be able to interact with the OpenStack services in the target mCloud environment


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


# HOW TO MANAGE NOVA SERVICES AND INSTANCES

```
NOTE: TO FIX THE INSTANCE WITH STATUS EQUALS ERROR

STEPS:
1. SSH TO mc.cb-1-1.morphcloud.net:35357
   => ssh -p 2222 root@mc.cb-1-1.morphcloud.net
   => press <enter>
   => type in <yes>
   => press <enter>
   => type in the password < server-password >
   => press <enter>

   Result will be:
   Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-24-generic x86_64)

   * Documentation:  https://help.ubuntu.com/

   System information as of Tue Jun  5 09:04:02 PHT 2012

   System load:  0.22                Users logged in:       0
   Usage of /:   34.1% of 170.06GB   IP address for eth0:   10.50.1.1
   Memory usage: 4%                  IP address for eth0:0: 10.60.1.1
   Swap usage:   0%                  IP address for eth1:   172.16.1.1
   Processes:    161                 IP address for virbr0: 192.168.122.1

   Graph this data and manage this system at https://landscape.canonical.com/

   21 packages can be updated.
   17 updates are security updates.

   Last login: Mon Jun  4 14:15:24 2012 from 119.93.17.130


2. Execute novarc.
   => type in < . novarc >

3. List all instance
   => type in < nova list --all >

   Result will be:

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

4. Check the nova config.
   => type in < cat novarc >


5. SSH to cn25
   => type in < ssh cn25 >
   => type in the password < server-password >

   Result will be:

   Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-24-generic x86_64)

   * Documentation:  https://help.ubuntu.com/

   System information as of Tue Jun  5 09:07:32 PHT 2012

   System load:  0.01                Users logged in:       0
   Usage of /:   38.4% of 170.06GB   IP address for eth0:   10.50.0.25
   Memory usage: 1%                  IP address for br100:  172.16.0.25
   Swap usage:   0%                  IP address for virbr0: 192.168.122.1
   Processes:    107

   Graph this data and manage this system at https://landscape.canonical.com/

   35 packages can be updated.
   18 updates are security updates.

   Last login: Mon Jun  4 16:55:01 2012 from 172.16.1.1

6. List all instance.

   => root@cn25.cb-1-1:~# virsh list --all

   Result will be:

   Id Name                 State
   ----------------------------------
   - instance-00000884    shut off
   - instance-0000088b    shut off
   - instance-00000890    shut off
   - instance-00000899    shut off
   - instance-000008b0    shut off
   - instance-000008b2    shut off
   - instance-000008b6    shut off

7. Double check for running instance.
   => root@cn25.cb-1-1:~# list=`virsh list --all|grep running | awk '{print $2}'`

8. Display inside list variable.
   => root@cn25.cb-1-1:~# echo $list

   Result will be:
   instance-00000884 instance-0000088b instance-00000890 instance-00000899 instance-000008b0 instance-000008b2 instance-000008b6

9. Change instance status to undefine.
   => root@cn25.cb-1-1:~# for i in $list; do virsh undefine $i; done

   Result will be:

   Domain instance-00000884 has been undefined

   Domain instance-0000088b has been undefined

   Domain instance-00000890 has been undefined

   Domain instance-00000899 has been undefined

   Domain instance-000008b0 has been undefined

   Domain instance-000008b2 has been undefined

   Domain instance-000008b6 has been undefined

10. Check for the instances having a state equals Shut Off
   => root@cn25.cb-1-1:~# virsh list --all

   Result will be:

    Id Name                 State
   ----------------------------------

11. Exit cn25
   => type in < exit > or < Ctrol + D >

12. Login to Postgre SQL
   => root@mc.cb-1-1:~# psql nova nova -W -h 172.16.1.1
   => type in password < db-password >

   Result will be:

   psql (9.1.3)
   SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
   Type "help" for help.

13. Update instance status.
   => nova=> update instances set deleted ='t' , deleted_at = now() where deleted ='f';

   Result will be:
   UPDATE 9

   => nova=> \q or < Ctrl + D >

14. List all Nova Service
   => root@mc.cb-1-1:~# nova-manage service list

   Result will be:

   Binary           Host                                 Zone             Status     State Updated_At
   nova-compute     cn25.cb-1-1.morphcloud.net           nova             enabled    XXX   2012-06-04 19:19:50.352503
   nova-scheduler   mc.cb-1-1.morphcloud.net             nova             enabled    XXX   2012-06-04 19:19:57.212497
   nova-volume      mc.cb-1-1.morphcloud.net             nova             enabled    XXX   2012-06-04 19:19:58.613001
   nova-network     cn25.cb-1-1.morphcloud.net           nova             enabled    XXX   2012-06-04 19:20:02.073767
   nova-consoleauth mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:14:34.437769
   nova-console     mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:14:35.887631

   NOTE: Check for the state "XXX"

15. Start the Nova Schedular
   => root@mc.cb-1-1:~# start nova-scheduler
   Result will be:
   nova-scheduler start/running, process 9858

16. Check the status of Nova Volume
   => root@mc.cb-1-1:~# status nova-volume
   Result will be:
   nova-volume stop/waiting

17. Start the Nova Volume.
   => root@mc.cb-1-1:~# start nova-volume
   Result will be:
   nova-volume start/running, process 9937
18. Check for the status of the Nova Volume.
   => nova-volume start/running, process 9937
   Result will be:
   nova-volume start/running, process 9937
19. Login to Postgre SQL
   => root@mc.cb-1-1:~# psql nova nova -W -h 172.16.1.1
   => type in password < db-password >
20. Check the status of the Nova Services.
   => root@mc.cb-1-1:~# nova-manage service list
   Result will be:
   Binary           Host                                 Zone             Status     State Updated_At
   nova-compute     cn25.cb-1-1.morphcloud.net           nova             enabled    XXX   2012-06-04 19:19:50.352503
   nova-volume      mc.cb-1-1.morphcloud.net             nova             enabled    XXX   2012-06-04 19:19:58.613001
   nova-network     cn25.cb-1-1.morphcloud.net           nova             enabled    XXX   2012-06-04 19:20:02.073767
   nova-console     mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:17:16.449901
   nova-scheduler   mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:17:17.650555
   nova-consoleauth mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:17:24.885023

   NOTE: Check for the state "XXX"

21. Check the status of the nova-volume.
   => root@mc.cb-1-1:~# status nova-volume
   Result will be:
   nova-volume start/running, process 9937

22. SSH to cn25
   => root@mc.cb-1-1:~# ssh cn25
   => type in password < server-password >

   Result will be:

   Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-24-generic x86_64)

   * Documentation:  https://help.ubuntu.com/

   System information as of Tue Jun  5 09:18:59 PHT 2012

   System load:  0.0                 Users logged in:       0
   Usage of /:   38.4% of 170.06GB   IP address for eth0:   10.50.0.25
   Memory usage: 1%                  IP address for br100:  172.16.0.25
   Swap usage:   0%                  IP address for virbr0: 192.168.122.1
   Processes:    105

   Graph this data and manage this system at https://landscape.canonical.com/

   35 packages can be updated.
   18 updates are security updates.

   Last login: Tue Jun  5 09:07:32 2012 from 172.16.1.1

23. Start the Nova Compute.
   => root@cn25.cb-1-1:~# start nova-compute
   Result will be:
   nova-compute start/running, process 5883

24. Start the Nova Network.
   => root@cn25.cb-1-1:~# start nova-network
   Result will be:
   nova-network start/running, process 5950

25. Check Nova Services
   => root@cn25.cb-1-1:~# nova-manage service list

   Result will be:
   Binary           Host                                 Zone             Status     State Updated_At
   nova-console     mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:47.001293
   nova-scheduler   mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:48.138922
   nova-compute     cn25.cb-1-1.morphcloud.net           nova             enabled    :-)   2012-06-05 01:19:52.098674
   nova-network     cn25.cb-1-1.morphcloud.net           nova             enabled    :-)   2012-06-05 01:19:52.298518
   nova-volume      mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:55.237728
   nova-consoleauth mc.cb-1-1.morphcloud.net             nova             enabled    :-)   2012-06-05 01:19:55.309350

   NOTE: You should all be good if you will not see state "XXX"
```

# Reset instances when ecnounter failed to start instance.

There are two steps. Reset db records and reset vms.

Reset db (in mc)

    root@mc.cb-1-1:~# psql nova nova -W -h 172.16.1.1
	Password for user nova: nova <- not displayed.
	psql (9.1.3)
	SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
	Type "help" for help.

	nova=> update instances set deleted ='t' , deleted_at = now() where deleted ='f';
	UPDATE XXX
	nova=> <ctrl+D>

Reset vms (in cn)

	root@mc.cb-1-1:~# ssh cn25
	Warning: Permanently added 'cn25' (ECDSA) to the list of known hosts.
	root@cn25's password: <<please enter root password>>

	root@cn25.cb-1-1:~# list=`virsh list --all|grep running | awk '{print $2}'`
	root@cn25.cb-1-1:~# for i in $list; do virsh destroy $i; done
	root@cn25.cb-1-1:~# list=`virsh list --all|grep shut| awk '{print $2}'`
	root@cn25.cb-1-1:~# for i in $list; do virsh undefine $i; done

# How you can connect nexenta server (volume server).

Step 1. Create port forwarding connection

     ssh -p 2222 root@mc.cb-1-1.morphcloud.net -L 2000:172.16.255.27:2000

Step 2. Access the URL using the browser

     http://localhost:2000
     username nova-cb-1-1
     password klnm12

The nexenta connection information is in /etc/nova/nova.conf

# Conect Fog

Move to bob directory and execute them.

  cd `bundle show fog`
  bundle install
  bundle exec irb

if you get error that require packages, please execute

  bundle install

In irb, you can call fog library like this.

  load './.irbrc'
  connect('admin', 'klnm12','<<tenant name>>','http://mc.cb-1-1.morphcloud.net:35357/')
  connection[:compute].volumes

# Using Chrome instead of firefox for running bob as test browser.
  # In Mac, use homebrew. For linux, download chromedriver from here:
  # http://code.google.com/p/chromedriver/downloads/list
  # Extract the file and copy to /usr/local/bin directory
  # and set the permission to 755.
  # Then set :chrome: true in config.yml
