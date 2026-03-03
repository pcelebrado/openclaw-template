# Base image
FROM mongo:latest

# Install curl
RUN apt-get update && apt-get install -y curl

# Copy the initiation script into the container
COPY --chmod=755 initiate-replica-set.sh /initiate-replica-set.sh

# Set the entrypoint to the initiation script
ENTRYPOINT ["/bin/bash", "/initiate-replica-set.sh"]