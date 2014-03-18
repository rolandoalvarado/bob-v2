# Working on your local copy of Bob-V2

Add https://github.com/rolandoalvarado/bob-v2 to your remote repos and nickname it as 'upstream'

    git remote add upstream git@github.com:rolandoalvarado/bob-v2.git

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

After the above, you can then send a pull request to upstream. Set the source branch to your topic branch's name and set the target branch to rolandoalvarado/master

# Test Fog via console

    bundle console
    irb > require File.expand_path('features/support/cloud_configuration.rb')
    irb > image_service    = Fog::Image.new(ConfigFile.cloud_credentials)
    irb > compute_service  = Fog::Compute.new(ConfigFile.cloud_credentials)
    irb > identity_service = Fog::Identity.new(ConfigFile.cloud_credentials)
    irb > volume_service   = Fog::Volume.new(ConfigFile.cloud_credentials)

You should now be able to interact with the OpenStack services in the target Cloud environment.

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
