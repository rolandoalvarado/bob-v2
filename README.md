mCloud Features
===============
This is an executable documentation of the features in all mCloud products. By executable, that means you
can run it and it will be automatically verified against an existing mCloud installation.

Prerequisites
-------------
1. [Git](http://git-scm.com)
2. [RVM](http://beginrescueend.com/) 1.10.2+
3. [Ruby](ruby-lang.org/) 1.9.3-p125 (Should be installed via RVM)
5. Mac Users: Xcode 4.1+ or the [Command Line Tools](https://developer.apple.com/downloads/index.action)

Got Xcode 4.2 or above?
-----------------------
You'll want to work around LLVM GCC. Here's [a suggestion](http://www.relaxdiego.com/2012/02/using-gcc-when-xcode-43-is-installed.html).

Installation
------------
1. `git clone https://bitbucket.org/mmaglana/mcloud_features`
2. `cd mcloud_features` (if RVM asks, trust the .rvmrc file)
3. `run/setup`

Usage
-----
1. `run/verifier`
2. There is no step 2

Found a bug?
------------
Report it [here](https://bitbucket.org/mmaglana/mcloud_features/issues/new).

Getting updates
------------
1. `git pull origin master`
2. `run/setup`

Contributing
------------
1. Fork `https://bitbucket.org/mmaglana/mcloud_features`
2. Create a branch for whatever it is you plan to do
3. Change stuff
4. Send a pull request. If I like it, I will merge to my master branch

Helpful references for development
----------------------------------
1. [Capybara DSL](http://rubydoc.info/github/jnicklas/capybara/master) - Learn about the DSL used in the tests.
2. [Cucumber](http://cukes.info) - Learn about the Cucumber framework. The Cucumber Book is highly recommended.
3. [Rspec-Rails](http://rubydoc.info/gems/rspec-rails/frames) - Background information about the testing framework used.
4. [Factory Girl](https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md) - Learn about the dynamic fixture library used in the tests.
5. [Guard](https://github.com/guard/guard) - Learn about what files are watched (for changes) and how tests gets executed automatically.