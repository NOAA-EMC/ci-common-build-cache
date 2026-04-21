# nceplibs Spack Environments

This directory contains Spack environment configurations for building nceplibs dependencies.

## Configuration Files

### Base Configurations (in `nceplibs/` subdirectory)

- **nceplibs/nceplibs-common.yaml** - Common configuration shared by all nceplibs environments
  - Contains shared package requirements and constraints
  - Includes all nceplibs core packages (bacio, g2, g2c, ip, w3emc) with common variants
  - Includes common dependencies (jasper, libpng, openblas, netcdf-fortran, etc.)
  - Includes test files (ip-test-files, bufr-test-files)

- **nceplibs/nceplibs-profilers-gcc.yaml** - Profiler tools (GCC compiler only)
  - Contains scalasca, hpctoolkit, and hpcviewer
  - **IMPORTANT**: Only compatible with GCC compiler
  - Should only be included when building with GCC

### Environment Configurations (in `applications/` directory)

- **nceplibs-develop.yaml** - Development versions (@develop) of nceplibs packages
  - Uses `packages:` configuration to require @develop versions
  - Specifies development-specific variants (e.g., +g2c_compare for g2)

- **nceplibs-numbered.yaml** - Released versions of nceplibs packages
  - Uses `packages:` configuration to require specific version numbers
  - Specifies production-specific variants (e.g., +extradeps for w3emc)
  - Production-ready configuration

### Optional Configurations

See **nceplibs/nceplibs-profilers-gcc.yaml** above in the Base Configurations section.

## Usage

### Basic Usage (without profilers)

```bash
# For development versions
spack env create nceplibs-dev applications/nceplibs-develop.yaml
spack env activate nceplibs-dev
spack install

# For numbered/released versions
spack env create nceplibs-num applications/nceplibs-numbered.yaml
spack env activate nceplibs-num
spack install
```

### With Profilers (GCC only)

To build with profilers, manually add the profilers include to your environment configuration:

**Option 1: Modify the YAML file**

Edit `nceplibs-develop.yaml` or `nceplibs-numbered.yaml` and update the include section:

```yaml
spack:
  include:
    - nceplibs-common.yaml
    - nceplibs-profilers-gcc.yaml  # Add this line for GCC builds
  specs:
    # ... rest/nceplibs-common.yaml
    - nceplibs/

**Option 2: Create a custom environment**

Create a new file `nceplibs-develop-gcc.yaml`:

```yaml
spack:
  include:
    - nceplibs-common.yaml
    - nceplibs-profilers-gcc.yaml
  specs:
  - bacio@deve/nceplibs-common.yaml
    - nceplibs/nceplibs-profilers-gcc.yaml
  packages:
    bacio:
      require: '@develop'
    # ... other packages composition**

```bash
# Create base environment
spack env create nceplibs applications/nceplibs-develop.yaml

# Add profilers to the environment
spack -e nceplibs config add "include:[applications/nceplibs-profilers-gcc.yaml]"

# Install
spack -e nceplibs install
```
/nceplibs
## Configuration Structure

The configuration follows Spack best practices:

1. **Modularity**: Common configuration is factored out into `nceplibs-common.yaml`
2. **Reusability**: Both develop and numbered environments share the common base
3. **Package-based Configuration**: Version and variant differences use the `packages:` section rather than duplicating specs
4. **Conditional Features**: Compiler-specific features (profilers) are isolated
5. **Maintainability**: Changes to common settings only need to be made in one place

The architecture uses Spack's configuration composition:
- **nceplibs-common.yaml** defines the package list in `specs:` with common variants
- **nceplibs-develop.yaml** and **nceplibs-numbered.yaml** use `packages:` to set version requirements
- This allows the same package to be included once but configured differently per environment

## Notes
/nceplibs-common.yaml** defines the package list in `specs:` with common variants
- **nceplibs-develop.yaml** and **nceplibs-numbered.yaml** use `packages:` to set version requirements
- This allows the same package to be included once but configured differently per environment
- Shared configuration files are organized in the `nceplibs/` subdirectory to separate them from the main environment files used by CI
- Add version/variant requirements to the `packages:` section in specific environment files
- Use common variants in the common specs, environment-specific variants in packages: configuration
- Update this README with any new conditional requirements

Example of adding a new package:
```yaml
# In nceplibs-common.yaml
specs:
  - newpackage +common_variant

# In nceplibs-develop.yaml  
packages:
  newpackage:
    require: '@develop +dev_specific_variant'

# In nceplibs-numbered.yaml
packages:
  newpackage:
    require: '@1.0.0 +prod_specific_variant'
```
## Maintenance

When adding new packages or requirements:
- Add package names to `nceplibs/nceplibs-common.yaml` specs if they apply to both environments
- Add version/variant requirements to the `packages:` section in specific environment files
- Use common variants in the common specs, environment-specific variants in packages: configuration
- Update this README with any new conditional requirements

Example of adding a new package:
```yaml
# In nceplibs/nceplibs-common.yaml
specs:
  - newpackage +common_variant

# In nceplibs-develop.yaml  
packages:
  newpackage:
    require: '@develop +dev_specific_variant'

# In nceplibs-numbered.yaml
packages:
  newpackage:
    require: '@1.0.0 +prod_specific_variant'
```
