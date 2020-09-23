# Moveto

```
$ pwd
/home/username/Documents
$ . moveto.bash --workdir /home/ .ssh
0: /home/username/Documents
1: /home/username/.ssh
Move to directory [0]: 1
$ pwd
/home/username/.ssh
``` 

## Usage
```
Finds directories up the directory structure
Gives an option to change to that found directory

Usage: source moveto.bash [-v] [-w <work dir>] <dir name to search>
  -h, --help      This text
  -v, --verbose   Set verbose flag
  -w, --workdir   Work from a directory other than the present working directory

Expects one (1) argument as a name of a directory
Example: source moveto.bash -v --workdir /home/ .ssh
```