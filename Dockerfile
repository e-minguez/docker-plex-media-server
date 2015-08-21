FROM fedora:latest

# Create plex user before install to avoid to be created by plex package
RUN useradd --uid 797 -d /usr/lib/plexmediaserver -c "PlexUser" --system -s /sbin/nologin plex && \
    mkdir /config && \
    chown plex:plex /config

# Install required packages
RUN dnf clean all && \
    dnf update -y && \
    dnf install -y $(curl -Ls https://plex.tv/downloads | grep "Fedora" | grep -o '[^"'"'"']*x86_64.rpm') && \
    dnf clean all

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
