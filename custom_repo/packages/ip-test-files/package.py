from spack_repo.builtin.build_systems.generic import Package

from spack.package import *


class IpTestFiles(Package):
    """This package provides ip test files from the FTP server."""

    homepage = "https://www.github.com/NOAA-EMC/NCEPLIBS-ip"
    url = "https://ftp.emc.ncep.noaa.gov/static_files/public/NCEPLIBS-ip/ip-test-data-20241230.tgz"

    maintainers("AlexanderRichert-NOAA")

    license("UNKNOWN", checked_by="github_user1")

    version(
        "20241230",
        sha256="3a33309f2451699c255717ffa60645f6c6862201a234b7bb77a340f5f5d345a8",
        expand=False,
    )

    def install(self, spec, prefix):
        install(self.stage.archive_file, prefix)
