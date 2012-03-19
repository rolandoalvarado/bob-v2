mCloud Features
===============
This is an executable documentation of the features in all mCloud products. By executable, that means you
can run it and it will be automatically verified against an existing mCloud installation.

Prerequisites
-------------
1. [Git](http://git-scm.com)
2. [RVM](http://beginrescueend.com/) 1.10.2+
3. [Ruby](ruby-lang.org/) 1.9.3-p125 (Should be installed via RVM)
5. Xcode 4.1+ or the [Command Line Tools](https://developer.apple.com/downloads/index.action)

Got Xcode 4.2 or above?
-----------------------
You'll want to work around LLVM GCC. Here's [a suggestion](http://www.relaxdiego.com/2012/02/using-gcc-when-xcode-43-is-installed.html).

Installation
------------
1. `git clone https://bitbucket.org/wdamarillo/mcloud_features`
2. `cd mcloud_features` (if RVM asks, trust the .rvmrc file)
3. `run/setup`

Usage
-----

To run the tests once and generate the progress report:

    run/verifier

The above command will generate the report in the `output` directory.

To run `verifier` everytime something changes in the feature or step files:

    run/autoverifier

To run the tests once in a CI environment:

    run/verifier ci

The above will generate two types of output: a junit report (for the CI), and an html report. Both will be located under the `output` directory.

To profile all steps in the test suite:

    run/profiler

Found a bug?
------------
Report it [here](https://bitbucket.org/wdamarillo/mcloud_features/issues/new).

Getting updates
------------
1. `git pull origin master`
2. `run/setup`

Contributing
------------
1. Fork `https://bitbucket.org/wdamarillo/mcloud_features`
2. Create a branch for whatever it is you plan to do. ALWAYS create a branch so that when there are changes in origin/master, you only need to rebase your branch and keep your commits in order. Also, this allows you to squash multiple commits into one before submitting a pull request.
3. Change stuff
4. Send a pull request

Helpful references for development
----------------------------------
1. [Gherkin Syntax](https://github.com/cucumber/cucumber/wiki/Gherkin) - If all you want is to write feature files, this is the only reference you need.
2. [Capybara DSL](http://rubydoc.info/github/jnicklas/capybara/master) - Learn about the DSL used in the tests.
3. [Cucumber](http://cukes.info) - Learn about the Cucumber framework. The Cucumber Book is highly recommended.
4. [Rspec-Rails](http://rubydoc.info/gems/rspec-rails/frames) - Background information about the testing framework used.
5. [Factory Girl](https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md) - Learn about the dynamic fixture library used in the tests.
6. [Guard](https://github.com/guard/guard) - Learn about what files are watched (for changes) and how tests gets executed automatically.
