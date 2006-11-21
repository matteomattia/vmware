# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils vmware

DESCRIPTION="Guest-os tools for VMware Workstation"
HOMEPAGE="http://www.vmware.com/"
SRC_URI="http://ftp.cvut.cz/vmware/${ANY_ANY}.tar.gz
	http://ftp.cvut.cz/vmware/obselete/${ANY_ANY}.tar.gz
	http://knihovny.cvut.cz/ftp/pub/vmware/${ANY_ANY}.tar.gz
	http://knihovny.cvut.cz/ftp/pub/vmware/obselete/${ANY_ANY}.tar.gz"
#	http://ftp.cvut.cz/vmware/${TOOLS_ANY}.tar.gz
#	http://ftp.cvut.cz/vmware/obselete/${TOOLS_ANY}.tar.gz
#	http://knihovny.cvut.cz/ftp/pub/vmware/${TOOLS_ANY}.tar.gz
#	http://knihovny.cvut.cz/ftp/pub/vmware/obselete/${TOOLS_ANY}.tar.gz"

LICENSE="vmware"
SLOT="0"
KEYWORDS="-* ~x86"
IUSE="X"
RESTRICT="strip"

RDEPEND="sys-apps/pciutils"

dir=/opt/vmware/tools
Ddir=${D}/${dir}

ANY_ANY=
TARBALL="vmware-linux-tools.tar.gz"
MY_P=${TARBALL/.tar.gz/}

S=${WORKDIR}/vmware-tools-distrib

src_install() {
	dodir ${dir}/bin
	cp -pPR bin/* ${Ddir}/bin || die

	dodir ${dir}/lib
	cp -dr lib/* ${Ddir}/lib || die
	# Since with Gentoo we compile everthing it doesn't make sense to keep
	# the precompiled modules arround. Saves about 4 megs of disk space too.
	rm -rf ${Ddir}/lib/modules/binary || die

	into ${dir}
	# install the binaries
	dosbin sbin/vmware-checkvm || die
	dosbin sbin/vmware-guestd || die

	# install the config files
	dodir ${etcdir}
	cp -pPR etc/* ${Detcdir} || die

	# install the init scripts
	newinitd ${FILESDIR}/${PN}.rc ${product} || die

	# Environment
	doenvd ${FILESDIR}/90${product} || die

	# if we have X, install the default config
	if use X ; then
		insinto /etc/X11
		doins ${FILESDIR}/xorg.conf
	fi

	vmware_create_initd || die

	cp -pPR installer/services.sh ${Detcdir}/init.d/${product} || die

	vmware_run_questions || die
}

pkg_postinst() {
	vmware_pkg_postinst
	einfo "To start using the vmware-tools, please run the following:"
	einfo
	einfo "  ${dir}/bin/vmware-config-tools.pl"
	einfo "  rc-update add vmware-tools default"
	einfo "  /etc/init.d/vmware-tools start"
	einfo
	einfo "Please report all bugs to http://bugs.gentoo.org/"
}
