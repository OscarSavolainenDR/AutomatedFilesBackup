# Automated Backup of Arbitrary, Distributed Files in Linux

This repo provides code to automatically backup any arbitrary collection of files to your private
Github. For example, I wanted to backup my Linux configuration, which was distributed across
multiple files and directories on my system. The code in this repository helps one be able to
create automatic backups, with fairly minimal setup. You'll just need to create some symlinks
and schedule a cronjob to trigger the backup as often as you want it.


The basic idea is to symlink arbitrary files to this directory (specifically in the `symlinks` 
sub-directory),. The `copy-symlink.sh` BASH script then copies over all of the symlinked 
files/folders into the `files` sub-directory.  The BASH script then commits all of the new changes
and pushes it all to Github. 
One can then set up a cronjob that automatically triggers the `copy-symlink.sh` script at whatever
time frame one wishes.
 
This way, you can edit all of your files inplace, and they get backed up to Github automatically.

## Important Notice:
MAKE SURE TO SET YOUR GITHUB REPOSITORY THAT YOU WILL PUSH TO TO PRIVATE. Otherwise you will push 
all of your symlinked files to a public repo. I would advice against working in this repository
directly, and instead to copy over the BASH files and to your own local repo, keeping the `symlinks`
folder structure. Alternatively, you can fork/clone this repo, and set your origin to your own 
private repo, e.g.
```
git remote add origin ssh-to-your-private-repo
```

PLEASE DO NOT push your private files to a public repo.

## How To Use:

All one has to do is to:

### 1) Add symlinks:

One has to add symlinks to whatever files/folders you would like to backup. The symlinks folder 
can be structured however one wishes, e.g.

+---Folder A
|   |   Symlink-folder 1
|   |   Symlinked file 1
|   \---Folder B
|           Symlinked file 2
\---Folder C
        Symlink-folder 2

This structure will be copied over the `files` by the BASH script. This allows one to structure
the backup directories/files however one wishes.

To add a symlink, run:
```
cd symlinks
ln -s [target] ./[name-of-desired-subdirectory-or-file]
```
where `target` is the path to the file/directory you want to include in your backup. E.g.
```
cd symlinks
ln -s ~/.bashrc ./basrhc
ln -s ~/.config/tmux ./config-files/tmux
```

You should check that all of your symlinks are working as expected before moving to the next step.

### 2) Schedule the cronjob
This is entirely optional. You may prefer to run the BASH script manually, or even to avoid pushing
to Github (or whatever your platform of choice). I have included two scripts: 
- `copy-symlinks.sh`: copies the files from the symlinks into `files` with the same structure as 
`symlinks`. However, this script doesn't work with a cronjob, and doesn't create commits or push 
to Github.
- `copy-symlinks-auto.sh`: copies the files from the symlinks, and works with a cronjob to push 
the files to Github.


To schedule a cronjob, one can use a cronjob command such as:
``` 
0 19 * * * git config --global --add safe.directory [PATH]; USER=[YOUR-LINUX-USERNAME] SSH_AUTH_SOCK=$(find /tmp/ssh-* -type s -user [YOUR-LINUX-USERNAME] 2>/dev/null | head -n 1) /bin/bash [PATH]/copy-symlinks-auto.sh > [PATH]/log-file.log 2>&1
```
with `PATH` equal to the path to this directory, e.g. `/home/username/Config`. 
```
0 19 * * *
```
represents that the script should run every evening at 19:00. However, one can schedule the backups
to happen at whatever frequency one wishes (the format consists of minute, hour, day of the month,
month, day of the week, where `*` is a wildcard).

To create a cronjob on Linux, run:
```
crontab -e
```
And add the above line to the end of your file, with whatever tiem schedule you wish. If this is 
your first time using `crontab`, you will have to select your text editor. Choose your favorite
text editor, but you can always change it  at anytime afterwards via running `select-editor` and
choosing again.

This cronjob will also log to a file `log-file.log`, and it may be useful for debugging issues
with the cronjob. However, this logging can be disabled by removing the re-direction from the end
of the cronjob command. I.e., remove `> [PATH]/log-file.log 2>&1` from the end of the command.

