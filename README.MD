GitWhatsNew - What's New Git?
==============

Purpose
--------------

*To easily view the latest work done in a local Git repository*

This script will display the latest edited branches and the latest commits on those branches.
The script will display your current branches, and the number of untracked and uncomitted files, if any.

**Output**

The output will be in the form of
```
Current branch  : X
Untracked files : Y
Uncomitted files: Z

branchName

        Commit: commitId
        Author: name <email@domain.com>
        Date  : Thu Jan 01 00:00:00 1970
                Commit Title
                Commit Body
```

**Usage**

*There are 4 optional parameters*

- -b number: The number of branches to show
- -c number: The number of commits to show (per branch)
- --me: Tells GitWhatsNew to only display commits from you
- --id: Display the ID of the commits

Example usage:

```bash
gitWhatsNew.bash [-b number] [-c number] [--onlyMyself] [--showCommitId]
user@computer:~$ gitWhatsNew.bash -b3 -c3 --me --id
```
Example output:
```
Current branch  : master
Untracked files : 1
Uncommited files: 1

branch3:

        Commit: 378f5bda4c00dfb6df65c31af2af6bf59941df4e
        Author: perroned <email@domain.com>
        Date  : Thu Apr 30 03:59:59 2015

                title for branch3 init commit
                Body for branch 3 init commit

        Commit: 0b1f12fd935aa4da059fac8cf25f1f1975adcfce
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 21:53:58 2015

                fancy title
                Fancy description

        Commit: dcc9709968ed47039c84dcea12c71ff6437663f3
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 21:50:45 2015

                added file2 on master

* On branch ==> master *

        Commit: 0b1f12fd935aa4da059fac8cf25f1f1975adcfce
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 21:53:58 2015

                fancy title
                Fancy description

        Commit: dcc9709968ed47039c84dcea12c71ff6437663f3
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 21:50:45 2015

                added file2 on master

        Commit: 7c007a4d97cc5860f4ef781e09fab663776e7c9f
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 20:38:04 2015

                added file on master

branch2:

        Commit: cd4e7f4e3d84b83d9e324de76b28095731a42ea9
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 20:40:27 2015

                added file on branch2

        Commit: 7c007a4d97cc5860f4ef781e09fab663776e7c9f
        Author: perroned <email@domain.com>
        Date  : Wed Apr 29 20:38:04 2015

                added file on master
```
&nbsp;
--------------
**Credits**
- [For moving to the root Git directory](http://stackoverflow.com/a/1571525)
- [For determining local work done on the repo](http://stackoverflow.com/a/2658301)
