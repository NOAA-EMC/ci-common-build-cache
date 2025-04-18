![workflowstatus](https://github.com/NOAA-EMC/ci-common-build-cache/actions/workflows/build.yaml/badge.svg)

# ci-common-build-cache

This repository contains CI workflows that use Spack to generate a GitHub Packages cache of pre-built dependency packages for various EMC codes.

Packages that must be provided by any GitHub Actions workflows using these packages:
- Spack (to concretize environment and access/install from build cache)
- Compilers (GCC, Intel Classic, Intel OneAPI; see .github/workflows/build.yaml for available versions; use apt or https://github.com/NOAA-EMC/ci-install-intel-toolkit to install)
- Intel MPI (see .github/workflows/build.yaml for available versions; use apt or https://github.com/NOAA-EMC/ci-install-intel-toolkit to install)

For a package that does not have its own Spack recipe (i.e., only its dependencies will be built through Spack), then to use the build cache, run the following prior to concretizing and installing a Spack environment:
```console
$ spack mirror add emc-common-build-cache oci://ghcr.io/NOAA-EMC/ci-common-build-cache
```

> [!NOTE]
> Currently, this CI workflow uses Spack commit [a9c879d](https://github.com/spack/spack/commit/a9c879d53e758f67cdbf4cec919425cb2a3a1082), which is the last commit of develop prior to the implementation of compilers as nodes (i.e., providers of c/cxx/fortran virtual packages). Those changes are substantial, significantly affect hashes/concretization, and still have some issues. If using these cached packages, be sure to use a commit prior to a9c879d, or simply use [ci-test-spack-package](https://github.com/NOAA-EMC/ci-test-spack-package) which will automatically use a copy of Spack at that commit.
