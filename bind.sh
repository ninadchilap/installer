#!/system/bin/sh

export bin=/system/bin
export PATH=$bin:/usr/bin:/usr/sbin:/bin:$PATH
export TERM=linux
export HOME=/root
export MNT=/data/local/linux
export EG=/data/example
export SDCARD=/mnt/sdcard/APL
export WWW=/data/local/linux/var/www/html

FLAG=1

while [ $FLAG -eq 1 ]
do
    
    while [ $(pgrep com.aakash.lab | wc -l) -eq 1 ]
    do
	
	if [ ! -d ${SDCARD} ] || [ ! -d ${WWW} ] || [ ! -d ${EG} ]
   
    then                                                                  
	    busybox mkdir -p ${SDCARD}/c/code                                         
	    busybox mkdir -p ${WWW}/c/code                                            
	    busybox mkdir -p ${EG}/c

	    busybox mkdir -p ${SDCARD}/cpp/code                                       
	    busybox mkdir -p ${WWW}/cpp/code                                          
	    busybox mkdir -p ${EG}/cpp

	    busybox mkdir -p ${SDCARD}/python/code                                     
	    busybox mkdir -p ${WWW}/python/code     
	    busybox mkdir -p ${EG}/python

	    busybox mkdir -p ${SDCARD}/scilab/code
	    busybox mkdir -p ${WWW}/scilab/code   
	    busybox mkdir -p ${EG}/scilab

	    busybox mkdir -p ${SDCARD}/scilab/image
	    busybox mkdir -p ${WWW}/scilab/image   
	fi
	sleep 0.2

	busybox  chroot  /data/local/linux /bin/bash -c "nohup python /root/sb_manage.py &>'/dev/null'&"
	busybox mount -o bind ${SDCARD}/c/code ${WWW}/c/code
	busybox mount -o bind ${SDCARD}/cpp/code ${WWW}/cpp/code
	busybox mount -o bind ${SDCARD}/python/code ${WWW}/python/code
	busybox mount -o bind ${SDCARD}/scilab/code ${WWW}/scilab/code
	busybox mount -o bind ${SDCARD}/scilab/image ${WWW}/scilab/image

	busybox mount -o bind ${EG}/c ${WWW}/c/exbind
	busybox mount -o bind ${EG}/cpp ${WWW}/cpp/exbind
	busybox mount -o bind ${EG}/python ${WWW}/python/exbind
	busybox mount -o bind ${EG}/scilab ${WWW}/scilab/exbind
    
    	
	FLAG=0
	exit 0 
    done
    sleep 2 
done

exit 0
