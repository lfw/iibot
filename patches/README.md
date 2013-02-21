# Patches
## SSL patch
This patch is taken directly from http://tools.suckless.org/ii/patches/ssl
The included patch was downloaded from http://tools.suckless.org/ii/patches/ii-1.7-ssl.diff  on 2013-02-19

`git apply patches/ii-1.7-ssl.diff`  

## SASL patch
This patch was written by me as a quick hack to add basic SASL authentication to ii
You have to specify -a <saslhash> on the command line.  PLAIN SASL hash can be obtained from the command line.  

`echo -ne "<nick>\0<username>\0<password>" | base64`  

## Patching ii
### Obtaining ii
The patches were based off of the git version ii-1.7 which was obtained with a git clone on 2013-02-19  

`git clone http://git.suckless.org/ii`  

The 1.7 code can also be obtained via tar ball.  

`wget http://dl.suckless.org/tools/ii-1.7.tar.gz`  

### Applying patches
The ssl patch must be applied first and then the sasl patch. If you are using GIT this can be done with the git apply command.  

`git apply /path/to/ii-1.7-ssl.diff`  
`git apply /path/to/ii-1.7-sasl.diff`  

If you are working with the tar ball this can be done with the patch command.  

`patch -p1 < /path/to/ii-1.7-ssl.diff`  
`patch -p1 < /path/to/ii-1.7-sasl.diff`  

### Compiling ii
After applying the ssl and sasl patches ii can be compiled as usual.  

`sudo make install clean` 
