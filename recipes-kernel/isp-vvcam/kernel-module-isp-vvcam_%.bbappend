FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
	    file://vvsensor.h \
	    file://vvcam.mk \
	    file://0001-isp-vvcam-framos.patch \
"


do_copy_files() {
    cp ${WORKDIR}/vvsensor.h ${WORKDIR}/git/vvcam/common
    cp ${WORKDIR}/vvcam.mk ${WORKDIR}/git/vvcam
}

addtask copy_files after do_patch before do_configure
