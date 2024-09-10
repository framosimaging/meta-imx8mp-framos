FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI += "file://0001-isp-imx-framos.patch" 

FILES_SOLIBS_VERSIONED += " \
    ${libdir}/libimx662.so \
    ${libdir}/libimx676.so \
    ${libdir}/libimx678.so \
    ${libdir}/libimx900.so \
"
