mCloud Features
===============
This the repository for mCloud requirements and their associated automated test
scripts. It is built with Cucumber which means that you can execute the
documentation and it will be automatically verified against an existing
mCloud installation. After verification, it will generate a
[business-friendly progress report](http://dl.dropbox.com/u/1355795/misc/progress_report.png).

Prerequisites
-------------
1. [Git](http://git-scm.com)
2. [Ruby](ruby-lang.org/) 1.9.2-p290 or higher

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

To run mCloud Features:

    run/verifier

The above command will generate a report in the `output` directory.

To automatically run mCloud Features every time something changes in any of
the files declared in [the Guardfile](https://bitbucket.org/wdamarillo/mcloud_features/src/master/Guardfile):

    run/autoverifier

Other useful commands
---------------------

Getting updates:

    run/updater

The above command will pull the latest changes from origin/master and run
`setup`. If you want to pull changes from another remote or branch, use:

    run/updater <remote_repo_name> <remote_branch_name>

__NOTE:__ The above command assumes that you've already set the URL for
`remote_repo_name`. For help on adding a remote repo to your local repo,
see [this page](http://progit.org/book/ch2-5.html).

To see a full list of available commands:

    run/help


Need More Help?
---------------
If you're stuck, email me at mmaglana@morphlabs.com or ping me through my Skype
ID mark.maglana. Optionally, you can suggest ways to further improve mCloud
Features by creating tickets [here](https://bitbucket.org/wdamarillo/mcloud_features/issues/new).

Contributing
------------
__NOTE:__ If you just plan on contributing to the .feature files every now
and then, you may skip this section and write .feature files directly.
Afterwards, email it to me and I will commit your file for you. If you plan on
contributing on an ongoing basis, we highly recommend you follow this process.

1. Fork `https://bitbucket.org/wdamarillo/mcloud_features`
2. Create a branch for whatever it is you plan to do. ALWAYS create a branch so that when there are changes in origin/master, you only need to rebase your local branch and keep your commits in order. Also, this allows you to squash multiple commits into one before submitting a pull request.
3. Change stuff
4. Send a pull request

How to write Features
---------------------
* Features are written as ordinary text files with a .feature extension under the `features/feature_files` directory
* The simplest .feature file can be written as:

  Listing 1. Sample .feature file

      Feature: Launch a VM

        Scenario Outline: Withdraw cash
          Given my account has a balance of <Balance>
           When I withdraw <Requested Amount>
           Then the amount will be <Dispensed or Not>

          Scenarios:
            | Balance | Requested Amount | Dispensed or Not |
            |    $100 |              $50 | Dispensed        |
            |    $100 |             $150 | Not Dispensed    |

* For more sample feature files, see [the actual mCloud Features feature files](https://bitbucket.org/wdamarillo/mcloud_features/src/375ec13be815/features/feature_files/).

Helpful references for development
----------------------------------
1. [Gherkin Syntax](https://github.com/cucumber/cucumber/wiki/Gherkin) - If all you want is to write feature files, this is the only reference you need.
1. [PO gem](https://github.com/relaxdiego/po) - Learn about the DSL used within the step definitions
1. [Cucumber](http://cukes.info) - Learn about the Cucumber framework. The Cucumber Book is highly recommended.
1. [Cucumber Mailing List](https://groups.google.com/forum/?fromgroups#!forum/cukes) - Get help from the community.
1. [Guard](https://github.com/guard/guard) - Learn about what files are watched (for changes) and how tests gets executed automatically.
