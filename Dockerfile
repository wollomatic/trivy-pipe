FROM aquasec/trivy:0.65.0

COPY pipe /

RUN apk --no-cache add bash && chmod +x /pipe.sh

ENTRYPOINT ["/pipe.sh"]
