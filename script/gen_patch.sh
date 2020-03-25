pwd=$(dirname $(readlink -f $0))
workdir=${pwd}/../
gen_patch()
{
	local version=$1
	cd ${workdir}/build-ipvs/$version-ipvs/ && make clean &&  cd ${workdir}
	diff -Nur kernel-src/$version/net/netfilter/ipvs/ build-ipvs/$version-ipvs/ > patch-ipvs/$version.patch
}
gen_patch $1
