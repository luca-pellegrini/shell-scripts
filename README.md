# Shell scripts

This is a small collection of shell scripts I made to carry out a few 
daily tasks, like backing up and syncing files between my laptop and 
desktop PCs, and monitoring my laptop battery status.

These scripts are in fact quite simple, so they don't really deserve their own
separate Git repo. Therefore, I keep all of them in this one repository.

They're located in the `bin` directory.

Small summary of the purposes of these scripts:

 - set a limit to battery charge on laptop (tested only on my ASUS VivoBook S15)
 - monitor the status of my laptop battery
 - sync files and directories between two PCs with rsync + SSH
 - backup files and directories to external drive with rsync

The scripts I use for backing up and syncing files are very specific to my use
case, but I decided to share them anyway, in case they may be of inspiration
for somebody else.

## Copying

The shell scripts in this repository are free software: you can
redistribute them and/or modify them under the terms of the GNU
General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

These programs are distributed in the hope that they will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with these programs.  If not, see <https://www.gnu.org/licenses/>.

Copyright (C) 2023  Luca Pellegrini
