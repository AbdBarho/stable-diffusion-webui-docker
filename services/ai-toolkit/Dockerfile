FROM ostris/aitoolkit:latest

ADD --chmod=755 entrypoint.sh /docker/

ENTRYPOINT ["/bin/bash", "/docker/entrypoint.sh"]
CMD ["/start.sh"]

