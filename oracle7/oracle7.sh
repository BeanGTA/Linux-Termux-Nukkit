#!/data/data/com.termux/files/usr/bin/bash

time1="$( date +"%r" )"

install1 () {
directory=oracle7-fs
ORACLE_VERSION=7
if [ -d "$directory" ];then
first=1
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;227m[WARNING]:\e[0m \x1b[38;5;87m Skipping the download and the extraction\n"
elif [ -z "$(command -v proot)" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Please install proot.\n"
printf "\e[0m"
exit 1
elif [ -z "$(command -v wget)" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Please install wget.\n"
printf "\e[0m"
exit 1
fi
if [ "$first" != 1 ];then
if [ -f "oracle7.tar.xz" ];then
rm -rf oracle7.tar.xz
fi
if [ ! -f "oracle7.tar.xz" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Downloading the oracle7 rootfs, please wait...\n"
ARCHITECTURE=$(dpkg --print-architecture)
case "$ARCHITECTURE" in
aarch64) ARCHITECTURE=arm64;;
arm) ARCHITECTURE=armhf;;
amd64|x86_64) ARCHITECTURE=amd64;;
*)
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Unknown architecture :- $ARCHITECTURE"
exit 1
;;

esac

wget https://www.dropbox.com/s/s0k90wjm9xagimc/oraclelinux7.tar.xz -q -O oracle7.tar.xz 
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Download complete!\n"

fi

cur=`pwd`
mkdir -p $directory
cd $directory
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Decompressing the oracle7 rootfs, please wait...\n"
tar -zxf $cur/oracle7.tar.xz --exclude='dev'||:
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m The oracle7 rootfs have been successfully decompressed!\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Fixing the resolv.conf, so that you have access to the internet\n"
printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > etc/resolv.conf
stubs=()
stubs+=('usr/bin/groups')
for f in ${stubs[@]};do
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Writing stubs, please wait...\n"
echo -e "#!/bin/sh\nexit" > "$f"
done
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Successfully wrote stubs!\n"
cd $cur

fi

mkdir -p oracle7-binds
bin=startoracle7.sh
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Creating the start script, please wait...\n"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
## uncomment following line if you are having FATAL: kernel too old message.
#command+=" -k 4.14.81"
command+=" --link2symlink"
command+=" -0"
command+=" -r $directory"
if [ -n "\$(ls -A oracle7-binds)" ]; then
    for f in oracle7-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
command+=" -b oracle7-fs/tmp:/dev/shm"
command+=" -b /data/data/com.termux"
command+=" -b /:/host-rootfs"
command+=" -b /sdcard"
command+=" -b /storage"
command+=" -b /mnt"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m The start script has been successfully created!\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Fixing shebang of startoracle7.sh, please wait...\n"
termux-fix-shebang $bin
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Successfully fixed shebang of startoracle7.sh! \n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Making startoracle7.sh executable please wait...\n"
chmod +x $bin
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Successfully made startoracle7.sh executable\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Cleaning up please wait...\n"
rm oracle7.tar.xz -rf
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m Successfully cleaned up!\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer thread/INFO]:\e[0m \x1b[38;5;87m The installation has been completed! You can now launch CentOS with ./startoracle7.sh\n"
printf "\e[0m"

}
if [ "$1" = "-y" ];then
install1
elif [ "$1" = "" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;127m[QUESTION]:\e[0m \x1b[38;5;87m Do you want to install oracle7-in-termux? [Y/n] "

read cmd1
if [ "$cmd1" = "y" ];then
install1
elif [ "$cmd1" = "Y" ];then
install1
else
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Installation aborted.\n"
printf "\e[0m"
exit
fi
else
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Installation aborted.\n"
printf "\e[0m"
fi
