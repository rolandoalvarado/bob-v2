# Test Fog via console

```
bundle console
irb > require File.expand_path('features/support/cloud_configuration.rb')
irb > image_service    = Fog::Image.new(ConfigFile.cloud_credentials)
irb > compute_service  = Fog::Compute.new(ConfigFile.cloud_credentials)
irb > identity_service = Fog::Identity.new(ConfigFile.cloud_credentials)
```

# Working on your local copy of MCF

Add wdamarillo/mcloud_features to your remote repos and nickname it as 'upstream'

    git remote add upstream git@bitbucket.org:wdamarillo/mcloud_features.git

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

# Save the HTML file to /tmp/hoge.html

# Testing CSS and XPath selectors using the Nokogiri gem

    bundle console
    html = Nokogiri::HTML.parse(File.open("/tmp/hoge.html"))

The `html` variable now points to a `Nokogiri::HTML::Document` object that you can
play around with. For example, assuming your html string contains an element
`<span class='label'>Here is my label</span>`:

    html.css(".label").count

The above will return a value of 1.

    html.css(".label").content

The above will return `Here is my label`

More info about the Nokogiri gem and its methods at [http://nokogiri.org/](http://nokogiri.org/).