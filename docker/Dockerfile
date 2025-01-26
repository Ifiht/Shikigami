FROM debian:bookworm-slim

#-=-> PRIVILEGED SETUP <=-=#
RUN apt-get update && apt-get install -y \
    ruby \
    beanstalkd \
    supervisor

COPY core/etc/supervisord.conf /etc/supervisor/
# Copy microservices and configuration files
COPY core/microservices/ /home/shikigami/
# Create a non-root user
RUN groupadd --gid 13133 shikigami && \
    useradd --uid 13133 --gid shikigami --shell /bin/bash --create-home shikigami
# Set ownership of the home directory
RUN chown -R shikigami:shikigami /home/shikigami/

#-=-> Non-root SETUP <=-=#
# Switch to the new user
USER shikigami
# Set the working directory
WORKDIR /home/shikigami

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]