FROM fedora:latest

# Create plex user before install to avoid to be created by plex package
RUN useradd --uid 797 -d /usr/lib/plexmediaserver -c "PlexUser" --system -s /sbin/nologin plex && \
    mkdir /config && \
    chown plex:plex /config

# Install required packages
# Get url from https://plex.tv/api/downloads/1.json
RUN dnf clean all && \
    dnf update -y && \
    curl -L 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=redhat' -o plexmediaserver.rpm && \
    dnf install -y plexmediaserver.rpm && \
    dnf clean all && \
    rm -f plexmediaserver.rpm

# Spotify support
#RUN dnf install -y nodejs && \
#    dnf clean all
# Then, download https://github.com/fuzeman/Spotify2.bundle/archive/master.zip
# Unzip it to your plugins folder (/config/Plex Media Server/Plug-ins) as Spotify2.bundle
# And set 797 ownership

# the number of plugins that can run at the same time
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS 6

# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE 3000

# location of configuration, default is
# "${HOME}/Library/Application Support"
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp

USER plex
WORKDIR /usr/lib/plexmediaserver

EXPOSE 32400

VOLUME ["/config","/media"]

CMD test -f /config/Plex\ Media\ Server/plexmediaserver.pid && rm -f /config/Plex\ Media\ Server/plexmediaserver.pid; \
    ulimit -s $PLEX_MAX_STACK_SIZE && ./Plex\ Media\ Server
