FROM drakkan/sftpgo:v2.7.0-slim

COPY --chmod=755 startup.sh /usr/local/bin/openclaw-sftpgo-startup.sh

EXPOSE 8080
EXPOSE 2022

ENTRYPOINT ["/usr/local/bin/openclaw-sftpgo-startup.sh"]
