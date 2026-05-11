{% if render_phase.bootstrap %}
{{ bootstrap.recipe }}

{% endif %}
{% if render_phase.build %}
# Build stage with Spack pre-installed and ready to be used
FROM {{ build.image }} AS builder

{% block build_stage %}
{% if os_packages_build %}
# Install OS packages needed to build the software
RUN {% if os_package_update %}{{ os_packages_build.update }} \
 && {% endif %}{{ os_packages_build.install }} {{ os_packages_build.list | join | replace('\n', ' ') }} \
 && {{ os_packages_build.clean }}
{% endif %}

# What we want to install and how we want to install it
# is specified in a manifest file (spack.yaml)
RUN mkdir -p {{ paths.environment }} && \
set -o noclobber \
{{ manifest }} > {{ paths.environment }}/spack.yaml
COPY spack.lock {{ paths.environment }}/spack.lock
COPY custom_repo {{ paths.environment }}/custom_repo
COPY nceplibs {{ paths.environment }}/nceplibs

# Install the software, remove unnecessary deps
#RUN spack --env {{ paths.environment }} repo remove custom_repo
RUN spack --env {{ paths.environment }} repo add '{{ paths.environment }}/custom_repo'
RUN cat {{ paths.environment }}/spack.yaml
RUN spack --env {{ paths.environment }} install --cache-only --no-check-signature --fail-fast
RUN spack --env {{ paths.environment }} gc -y

{% if strip %}
# Strip all the binaries
RUN find -L {{ paths.view }}/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | \
    grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | grep -v libhpcrun.a | xargs strip
{% endif %}

# Modifications to the environment that are necessary to run
RUN cd {{ paths.environment }} && \
    spack env activate --sh -d . > activate.sh

# Record Spack installation location and version for later reference
RUN echo "Spack is installed at: $(command -v spack)" && \
    echo "Spack root: $(spack location --spack-root)" && \
    spack --version

# Install spack-helpers extension source for inclusion in final image.
RUN git clone --depth 1 --branch develop https://github.com/NOAA-EMC/spack-helpers.git /opt/spack-helpers

{% endblock build_stage %}
{% endif %}

{% if render_phase.final %}
# Bare OS image to run the installed executables
FROM {{ run.image }}

# Copy compiled packages and Spack installation from builder
COPY --from=builder {{ paths.environment }} {{ paths.environment }}
COPY --from=builder {{ paths.store }} {{ paths.store }}
{# paths.view is a symlink, so copy the parent to avoid dereferencing and duplicating it #}
COPY --from=builder {{ paths.view_parent }} {{ paths.view_parent }}

# Copy Spack installation to enable customization via spack install
COPY --from=builder /opt/spack /opt/spack

# Copy Spack extension helpers into the requested final image location
COPY --from=builder /opt/spack-helpers /opt/spack-helpers

# Set up Spack environment for use in container
ENV SPACK_ROOT=/opt/spack \
    PATH=/opt/spack/bin:$PATH

# Register the extension once in the image after activating Spack.
RUN /bin/bash -lc 'source /opt/spack/share/spack/setup-env.sh && source /opt/spack-helpers/source_me.sh'

RUN { \
        echo '#!/bin/sh' \
      && echo 'export SPACK_ROOT=/opt/spack' \
      && echo 'export PATH=/opt/spack/bin:$PATH' \
      && echo '.' {{ paths.environment }}/activate.sh \
      && echo 'exec "$@"'; \
    } > /entrypoint.sh \
&& chmod a+x /entrypoint.sh \
&& ln -s {{ paths.view }} {{ paths.former_view }}

{% block final_stage %}

COPY install-intel.sh /opt/install-intel.sh

{% if os_packages_final %}
RUN {% if os_package_update %}{{ os_packages_final.update }} \
 && {% endif %}{{ os_packages_final.install }} {{ os_packages_final.list | join | replace('\n', ' ') }} \
 && {{ os_packages_final.clean }}
{% endif %}

# Ensure versionless GNU compiler paths exist when only versioned binaries are installed.
RUN set -e; \
        for tool in gcc g++ gfortran; do \
            candidate=$(ls /usr/bin/${tool}-[0-9]* 2>/dev/null | sort -V | tail -n1 || true); \
            if [ -n "${candidate}" ]; then \
                priority=${candidate##*-}; \
                update-alternatives --install /usr/bin/${tool} ${tool} ${candidate} ${priority}; \
            fi; \
        done
{% endblock final_stage %}
{% for label, value in labels.items() %}
LABEL "{{ label }}"="{{ value }}"
{% endfor %}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/bin/bash" ]
{% endif %}
