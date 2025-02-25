############################# START #############################
###### 
### Dockerfile uses Oracle Linux 9 which already has postgres in base image
# Use Oracle Linux 9 as the base image
FROM oraclelinux:9

# Install required packages and set up PostgreSQL repository
RUN dnf -y install dnf-plugins-core wget openssh-server which telnet nc tree perl-App-cpanminus \
    && dnf clean all \
    && rm -rf /var/cache/dnf/*pgdg* \
    && wget --quiet https://download.postgresql.org/pub/repos/yum/keys/RPM-GPG-KEY-PGDG -O /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG \
    && wget --quiet https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm -O /tmp/pgdg-redhat-repo-latest.noarch.rpm \
    && rpm -ivh /tmp/pgdg-redhat-repo-latest.noarch.rpm \
    && dnf -y install epel-release postgresql16 postgresql16-server postgresql16-contrib pg_top --nogpgcheck --nobest \
    && cpanm install Text::CSV_XS \
    && dnf -y install pgbadger --nogpgcheck --nobest --skip-broken \
    && dnf clean all \
    #
    # Update GPG Keys: https://yum.postgresql.org/news/pgdg-rpm-repo-gpg-key-update/
    && dnf --disablerepo=* -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-aarch64/pgdg-redhat-repo-latest.noarch.rpm \
    && dnf config-manager --enable ol9_codeready_builder \
    && dnf -y install repmgr_16 libmemcached pgpool-II pgbouncer python3 python3-pip \
    && pip3 install patroni[etcd]

# Create a PostgreSQL user and group if they do not already exist
RUN id -u postgres &>/dev/null || useradd -r -g postgres postgres

# Create data directory and set permissions
RUN mkdir -p /var/lib/pgsql/16/data /var/lib/pgsql/16/log /var/lib/pgsql/16/conf \
    && chown -R postgres:postgres /var/lib/pgsql

# Set environment variables for PostgreSQL and update PATH
ENV PGDATA=/var/lib/pgsql/16/data
ENV PGDATABASE=postgres
ENV PGCONF=/var/lib/pgsql/16/conf
ENV PGLOG=/var/lib/pgsql/16/log/pglog.log
ENV PGPORT=5432
ENV PATH=$PATH:/usr/pgsql-16/bin
ENV PS1='\u@\h:\w\$ '

# Switch to the postgres user
USER postgres

# Initialize PostgreSQL data directory
RUN /usr/pgsql-16/bin/initdb -D $PGDATA

# Update PostgreSQL configuration
RUN echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf \
    && echo "port = 5432" >> $PGDATA/postgresql.conf \
    && echo "host all all 0.0.0.0/0 md5" >> $PGDATA/pg_hba.conf \
    && echo "host all all ::/0 md5" >> $PGDATA/pg_hba.conf

# Set password for postgres user securely using Docker secret
RUN --mount=type=secret,id=postgres_password \
    echo "ALTER USER postgres WITH PASSWORD 'pookie';" > /tmp/password.sql && \
    /usr/pgsql-16/bin/pg_ctl -D $PGDATA -o "-c listen_addresses='*'" -w start && \
    psql -f /tmp/password.sql && \
    /usr/pgsql-16/bin/pg_ctl -D $PGDATA -m fast -w stop && \
    rm /tmp/password.sql

# Modify .bash_profile and .bashrc to echo environment variables and update PATH
RUN echo 'export PATH=$PATH:/usr/pgsql-16/bin' >> /var/lib/pgsql/.bash_profile \
    && echo 'export PATH=$PATH:/usr/pgsql-16/bin' >> /var/lib/pgsql/.bashrc \
    && echo 'echo "PGDATA=$PGDATA"' >> /var/lib/pgsql/.bashrc \
    && echo 'echo "PGDATABASE=$PGDATABASE"' >> /var/lib/pgsql/.bashrc \
    && echo 'echo "PGCONF=$PGCONF"' >> /var/lib/pgsql/.bashrc \
    && echo 'echo "PGLOG=$PGLOG"' >> /var/lib/pgsql/.bashrc \
    && echo 'echo "PGPORT=$PGPORT"' >> /var/lib/pgsql/.bashrc \
    && echo 'pg_ctl status -D $PGDATA' >> /var/lib/pgsql/.bashrc

# Switch back to root to configure SSH and finalize setup
USER root

# Configure SSH server
RUN echo "root:pookie" | chpasswd \
    && sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && mkdir /var/run/sshd \
    && ssh-keygen -A

# Create start script for SSH and PostgreSQL
RUN echo '#!/bin/bash' > /usr/local/bin/start_services.sh \
    && echo 'export PATH=$PATH:/usr/pgsql-16/bin' >> /usr/local/bin/start_services.sh \
    && echo 'echo "Current PATH: $PATH"' >> /usr/local/bin/start_services.sh \
    && echo 'ls -l /var/lib/pgsql/16' >> /usr/local/bin/start_services.sh \
    && echo 'ls -l /usr/pgsql-16/bin' >> /usr/local/bin/start_services.sh \
    && echo '/usr/sbin/sshd' >> /usr/local/bin/start_services.sh \
    && echo 'sleep 5' >> /usr/local/bin/start_services.sh \
    && echo 'su - postgres -c "/usr/pgsql-16/bin/pg_ctl start -D /var/lib/pgsql/16/data -l /var/lib/pgsql/16/log/pglog.log"' >> /usr/local/bin/start_services.sh \
    && echo 'tail -f /var/lib/pgsql/16/log/pglog.log' >> /usr/local/bin/start_services.sh \
    && chmod +x /usr/local/bin/start_services.sh

# Expose PostgreSQL and SSH ports
EXPOSE 5432 22

# Start SSH and PostgreSQL server
CMD ["/bin/bash", "/usr/local/bin/start_services.sh"]
###### 
############################# END #############################
