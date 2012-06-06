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

# Working on your local copy of MCF

Add wdamarillo/bob to your remote repos and nickname it as 'upstream'

    git remote add upstream git@bitbucket.org:wdamarillo/bob.git

Create a topic branch where you will commit your local work

    git checkout master
    git checkout -b create_a_project

Get the latest changes from upstream

    git fetch upstream

After the above command is done, all upstream/* branches should have the latest commits. You can see all upstream/* branches by running the following command:

    git branch -r

To merge upstream/master to your local master branch

    git checkout master
    git merge upstream/master

To sync your topic branch with your local master branch

    git checkout create_a_project
    git merge master

To push your topic branch to your remote repo

    git push origin create_a_project

After the above, you can then send a pull request to wdamarillo. Set the source branch to your topic branch's name and set the target branch to wdamarillo/master



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

  cd `bundle show fog`
  bundle install
  bundle exec irb

if you get error that require packages, please execute

  bundle install 

In irb, you can call fog library like this.

  load './.irbrc'
  connect('admin', 'klnm12','<<tenant name>>','http://mc.cb-1-1.morphcloud.net:35357/')
  connection[:compute].volumes

