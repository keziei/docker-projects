# Use Rocky Linux as the base image
FROM rockylinux:9

# Enable EPEL repository for extra packages
RUN dnf install -y epel-release && dnf clean all

# Install PostgreSQL 17 and requested utilities
RUN dnf install -y \
    postgresql-server postgresql-contrib \
    sed dos2unix vim-minimal procps-ng htop iproute iputils net-tools sysstat \
    && dnf clean all

# Set environment variables
ENV PGDATA=/var/lib/pgsql/data

# Ensure PostgreSQL directories exist and have correct permissions
RUN mkdir -p /var/run/postgresql && \
    chown -R postgres:postgres /var/run/postgresql && \
    chmod 775 /var/run/postgresql

# Create PostgreSQL data directory and set permissions
RUN mkdir -p ${PGDATA} && chown -R postgres:postgres ${PGDATA}

# Switch to the postgres user
USER postgres

# Initialize the PostgreSQL database
RUN /usr/bin/initdb -D ${PGDATA}

# Expose PostgreSQL port
EXPOSE 5432 5433 5434

# Start PostgreSQL as the postgres user
CMD ["/usr/bin/postgres", "-D", "/var/lib/pgsql/data"]
