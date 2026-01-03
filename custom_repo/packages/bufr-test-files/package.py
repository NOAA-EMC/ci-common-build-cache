from spack_repo.builtin.build_systems.generic import Package

from spack.package import *


class BufrTestFiles(Package):
    """This package provides NCEPLIBS-bufr test files from the FTP server."""

    homepage = "https://www.github.com/NOAA-EMC/NCEPLIBS-bufr"
    

    maintainers("AlexanderRichert-NOAA")

    license("UNKNOWN", checked_by="github_user1")

    version(
        "12.2.0",
        sha256="449f9b61b6c8e5b806bbd702736c9a241367d2c78033953c8009c367dcd3dc37",
        extension="tgz",
        url = "https://ftp.emc.ncep.noaa.gov/static_files/public/bufr-12.2.0.tgz.2"
    )

    def install(self, spec, prefix):
        install_tree(".", join_path(prefix, "share"))
