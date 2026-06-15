from spack_repo.builtin.build_systems.generic import Package

from spack.package import *


class BufrTestFiles(Package):
    """This package provides NCEPLIBS-bufr test files from the FTP server."""

    homepage = "https://www.github.com/NOAA-EMC/NCEPLIBS-bufr"
    

    maintainers("AlexanderRichert-NOAA")

    license("UNKNOWN", checked_by="github_user1")

    version(
        "12.2.0",
        sha256="0ebc27f6260dc964d38c3966fb583e3ef68279a9879fc28cd4d923e2fc2ea42c",
        extension="tgz",
        url = "https://ftp.emc.ncep.noaa.gov/static_files/public/bufr-12.2.0.tgz"
    )

    def install(self, spec, prefix):
        install_tree(".", prefix)
