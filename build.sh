pwd=$(dirname $(readlink -f $0))
build_dir=build-ipvs
ipvs=net/netfilter/ipvs

mkdir -p ${build_dir}

gen_makefile()
{
	grep KERNELDIR Makefile > 0
	if [ $? -eq 0 ]; then
		return 0
	fi
cat <<EOF>> Makefile
# build ipvs as kernel module out of kernel source tree
KERNELDIR ?=/lib/modules/\$(shell uname -r)/build
PWD :=\$(shell pwd)
default:
	\$(MAKE) -C \$(KERNELDIR) M=\$(PWD) \$(CONFIGS) modules

clean:
	@rm -rf *.o *~ core .depend .*.cmd *.ko *.ko.unsigned *.mod.c .tmp_versions \
	Module.symvers modules.order

.PHONY: modules modules_install clean
EOF
}

patch_ipvs()
{
	cat patch-ipvs/$1.patch |patch -tp0
}

build_ipvs()
{
	echo build $version
	cd ./kernel-src && cat $version.*| tar -xz  && cd ..
	cp ./kernel-src/${version}/${ipvs} ${build_dir}/${version}-ipvs -r
	patch_ipvs $version
	cd ./${build_dir}/${version}-ipvs
	gen_makefile
	make && mkdir -p ../$version-ipvs-ko && mv ./*.ko ../$version-ipvs-ko
	cd ../../
}

if [ $# != 1 ];then
	echo "need kernel-version"
	echo "usage: ./$0 $(for i in $(cat kernel-src/current);do echo -n " $i ";done)"
	exit 0
fi
version=$1
build_ipvs
