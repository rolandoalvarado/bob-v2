mCloud Features
===============
This is an executable documentation of the features in the mCloud product suite. By executable, that means you can run it and it will be automatically verified against an existing mCloud installation. After verification, it will generate a [business-friendly progress report](http://dl.dropbox.com/u/1355795/misc/progress_report.png).

Prerequisites
-------------
1. [Git](http://git-scm.com)
2. [Ruby](ruby-lang.org/) 1.8.7 or higher

Additional Prerequisites for Mac OS X
-------------------------------------
1. Xcode 4.1+ or the [Command Line Tools](https://developer.apple.com/downloads/index.action)
2. If you have Xcode 4.2 or above, you'll need to work around LLVM GCC. Here's [a suggestion](http://www.relaxdiego.com/2012/02/using-gcc-when-xcode-43-is-installed.html).

Installation
------------
1. `git clone git@bitbucket.org:wdamarillo/mcloud_features.git`
2. `cd mcloud_features`
3. `run/setup`

Usage
-----

To run the tests and generate the progress report:

    run/verifier

The above command will generate the report in the `output` directory.

To run `verifier` everytime something changes in the feature or step files:

    run/autoverifier

To run the tests in a CI environment:

    run/verifier ci

The above will generate two types of output: a junit report (for the CI), and an html report. Both will be located under the `output` directory.

To profile all steps in the test suite:

    run/profiler

To get a listing of step definitions and the feature files that use them:

    run/inventory

Note: The above command is also useful for finding out which step definitions are not currently in use.

Found a bug?
------------
Report it [here](https://bitbucket.org/wdamarillo/mcloud_features/issues/new).

Getting updates
------------
    run/updater

The above command will pull the latest changes from origin/master and run `setup`. If you want to pull changes from another remote or branch, use:

    run/updater <other_remote_repo> <my_branch>

Contributing
------------
1. Fork `https://bitbucket.org/wdamarillo/mcloud_features`
2. Create a branch for whatever it is you plan to do. ALWAYS create a branch so that when there are changes in origin/master, you only need to rebase your branch and keep your commits in order. Also, this allows you to squash multiple commits into one before submitting a pull request.
3. Change stuff
4. Send a pull request

How to write Features
---------------------

    
* Features are written as ordinary text files with a .feature extension under the `features` directory
* The simplest .feature file can be written as:

<pre><code>    Feature: Launch a VM

      Scenario: Succesfully launch a VM
        Given a machine image exists
         When I try to launch it
         Then it should be online in 20 minutes
      
      Scenario: Gracefully fail
        Given a bad machine image exists
         When I try launch it
         Then the system should alert me by email
</code></pre>

* For a more extensive guide on how to write feature files, see [https://gist.github.com/2128650](https://gist.github.com/2128650)

Helpful references for development
----------------------------------
1. [Gherkin Syntax](https://github.com/cucumber/cucumber/wiki/Gherkin) - If all you want is to write feature files, this is the only reference you need.
2. [Capybara DSL](http://rubydoc.info/github/jnicklas/capybara/master) - Learn about the DSL used in the tests.
3. [Cucumber](http://cukes.info) - Learn about the Cucumber framework. The Cucumber Book is highly recommended.
4. [Rspec-Rails](http://rubydoc.info/gems/rspec-rails/frames) - Background information about the testing framework used.
5. [Factory Girl](https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md) - Learn about the dynamic fixture library used in the tests.
6. [Guard](https://github.com/guard/guard) - Learn about what files are watched (for changes) and how tests gets executed automatically.
