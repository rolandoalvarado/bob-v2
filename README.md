Bob the mCloud Bot
==================
![Bob](http://dl.dropbox.com/u/1355795/bob.jpg "Bob")

Bob is the central repository for mCloud business requirements. It is used by:

* PPC to record product requirements
* Engineering to understand what to implement
* QA to auto-verify an mCloud environment, and
* Documentation to keep track of what features are supported by mCloud.

Bob is built with Cucumber and Ruby. His eye is made out of a knob, and it goes to eleven.

Prerequisites for Mac OS X 
-------------------------------------
1. Xcode 4.4.1+(10.7 later) or the [Command Line Tools](https://developer.apple.com/downloads/index.action)
2. If you have Xcode 4.2 or above, you'll need to work around LLVM GCC. Here's [a suggestion](http://www.relaxdiego.com/2012/02/using-gcc-when-xcode-43-is-installed.html).
3. Install [Homebrew](http://mxcl.github.com/homebrew/)
 `ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)`
4. Install git
 `brew install git`
 
Prerequisites for Ubuntu
-------------------------------------
1. Install the required packages:

  * `$ sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion xvfb`


Common Requirements
-------------
1. [RVM](http://beginrescueend.com) (Highly recommended)

  * `$ curl -L https://get.rvm.io | bash -s stable --ruby`
  * `$ source ~/.rvm/scripts/rvm`

2. [QT](http://qt.nokia.com/products/) (You'll need this to use the Capybara Webkit driver)


Installation
------------
1. Make sure you have accomplished the steps indicated in the *Prerequisites* and *Common Requirements* section.
2. `git clone git@github.com:[your forked repository]/bob.git`
3. `cd bob`
4. `run/setup`

Having trouble in executing run/setup?
------------
1. Edit $vi ~/.bashrc
2. add these lines: 

   if [[ -s $HOME/.rvm/scripts/rvm ]] then
      source $HOME/.rvm/scripts/rvm
   fi

3. Still won’t work? Add this instead:

   if [ -f /usr/share/ruby-rvm/scripts/rvm ]; then
      source /usr/share/ruby-rvm/scripts/rvm
   fi

4. Still won’t work? Sometimes, GEM_HOME environment variable may cause. So

   export GEM_HOME=
   
	
Usage
-----

To test Bob :

    run/tag @jira-MCF-4

If you want to execute full test (it takes 3 hours):
    run/verifier

    The above command makes Bob generate a report in the `output` directory.


Other useful commands
---------------------

Updating Bob:

    run/updater

The above command tells Bob to fetch the latest changes from origin/master, merge it to the current branch, and execute `run/setup`. If you want Bob to fetch and merge changes from another remote or branch, use:

    run/updater <remote_repo_name> <remote_branch_name>

__NOTE:__ The above command assumes that you've already set the URL for
`remote_repo_name`. For help on adding a remote repo to your local repo,
see [this page](http://progit.org/book/ch2-5.html).

To see a full list of available commands you can give Bob:

    run/help


Need More Help?
---------------
If you're stuck, email me at ttakekawa@morphlabs.com or ping me through my Skype. Optionally, you can suggest ways to further improve Bob by creating tickets [here](https://issues.morphlabs.com/browse/MCF).

Contributing
------------
__NOTE:__ If you just plan on contributing to the .feature files every now
and then, you may skip this section and write .feature files directly.
Afterwards, email it to me and I will commit your file for you. If you plan on
contributing on an ongoing basis, I highly recommend you follow this process.

1. Fork `https://github.com/MorphGlobal/bob`
2. Create a branch for whatever it is you plan to do. ALWAYS create a branch so that when there are changes in wdamarillo/master, you only need to rebase your local branch and keep your commits in order. Also, this allows you to squash multiple commits into one before submitting a pull request.
3. Change stuff
4. Add your ssh pub key to github https://github.com/settings/ssh 
5. Send a pull request

How to write Features
---------------------
* Features are written as ordinary text files with a .feature extension under the `features/1_feature_files` directory
* The simplest .feature file can be written as:

  Listing 1. Sample .feature file

      Feature: Withdraw Money

        Scenario Outline: Withdraw an amount given a starting balance
          Given my account has a balance of <Balance>
           When I withdraw <Requested Amount>
           Then the amount will be <Dispensed or Not>

          Scenarios:
            | Balance | Requested Amount | Dispensed or Not |
            |    $100 |              $50 | Dispensed        |
            |    $100 |             $150 | Not Dispensed    |

* For more sample feature files, see [the actual feature files](https://github.com/MorphGlobal/bob/src/master/features/feature_files/).

Helpful references for development
----------------------------------
1. [Gherkin Syntax](https://github.com/cucumber/cucumber/wiki/Gherkin) - If all you want is to write feature files, this is the only reference you need.
1. [Cucumber](http://cukes.info) - Learn about the Cucumber framework. The Cucumber Book is highly recommended.
1. [Cucumber Mailing List](https://groups.google.com/forum/?fromgroups#!forum/cukes) - Get help from the community.
