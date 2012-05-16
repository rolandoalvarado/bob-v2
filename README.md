Bob the mCloud Bot
==================
![Bob](http://dl.dropbox.com/u/1355795/bob.jpg "Bob")

Bob is the central repository for mCloud business requirements. It is used by:

* PPC to record product requirements
* Engineering to understand what to implement
* QA to auto-verify an mCloud environment, and
* Documentation to keep track of what features are supported by mCloud.

Bob is built with Cucumber and Ruby. His eye is made out of a knob, and it goes to eleven.

Prerequisites
-------------
1. [Git](http://git-scm.com)
2. [Ruby](ruby-lang.org/) 1.9.3-p125 or higher

Optional Stuff
--------------

1. [RVM](http://beginrescueend.com) (Highly recommended)

Additional Prerequisites for Mac OS X
-------------------------------------
1. Xcode 4.1+ or the [Command Line Tools](https://developer.apple.com/downloads/index.action)
2. If you have Xcode 4.2 or above, you'll need to work around LLVM GCC. Here's [a suggestion](http://www.relaxdiego.com/2012/02/using-gcc-when-xcode-43-is-installed.html).

Installation
------------
1. `git clone git@bitbucket.org:wdamarillo/bob.git`
2. `cd bob`
3. `run/setup`

Usage
-----

To make Bob verify an mCloud environment:

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
If you're stuck, email me at mmaglana@morphlabs.com or ping me through my Skype
ID mark.maglana. Optionally, you can suggest ways to further improve Bob by creating tickets [here](https://issues.morphlabs.com/browse/MCF).

Contributing
------------
__NOTE:__ If you just plan on contributing to the .feature files every now
and then, you may skip this section and write .feature files directly.
Afterwards, email it to me and I will commit your file for you. If you plan on
contributing on an ongoing basis, I highly recommend you follow this process.

1. Fork `https://bitbucket.org/wdamarillo/bob`
2. Create a branch for whatever it is you plan to do. ALWAYS create a branch so that when there are changes in wdamarillo/master, you only need to rebase your local branch and keep your commits in order. Also, this allows you to squash multiple commits into one before submitting a pull request.
3. Change stuff
4. Send a pull request

How to write Features
---------------------
* Features are written as ordinary text files with a .feature extension under the `features/feature_files` directory
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

* For more sample feature files, see [the actual feature files](https://bitbucket.org/wdamarillo/bob/src/master/features/feature_files/).

Helpful references for development
----------------------------------
1. [Gherkin Syntax](https://github.com/cucumber/cucumber/wiki/Gherkin) - If all you want is to write feature files, this is the only reference you need.
1. [Cucumber](http://cukes.info) - Learn about the Cucumber framework. The Cucumber Book is highly recommended.
1. [Cucumber Mailing List](https://groups.google.com/forum/?fromgroups#!forum/cukes) - Get help from the community.
