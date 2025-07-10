FROM aquasec/trivy:0.64.1

COPY pipe /

RUN apk --no-cache add bash && chmod +x /pipe.sh

ENTRYPOINT ["/pipe.sh"]
