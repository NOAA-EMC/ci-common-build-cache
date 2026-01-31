from spack_repo.builtin.build_systems.generic import Package

from spack.package import *


class BufrTestFiles(Package):
    """This package provides NCEPLIBS-bufr test files from the FTP server."""

    homepage = "https://www.github.com/NOAA-EMC/NCEPLIBS-bufr"
    

    maintainers("AlexanderRichert-NOAA")

    license("UNKNOWN", checked_by="github_user1")

    version(
        "12.4.0",
        sha256="db756d2de2c994a33628d3d777bcfa43ad34c3ff54159df2d97426d3e6371449",
        extension="tgz",
        url = "https://ftp.emc.ncep.noaa.gov/static_files/public/bufr-12.4.0.tgz"
    )

    def install(self, spec, prefix):
        install_tree(".", prefix)
