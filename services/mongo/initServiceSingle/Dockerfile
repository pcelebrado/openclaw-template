# Base image — pinned to match the primary mongo:7 node
FROM mongo:7

# Install curl
RUN apt-get update && apt-get install -y curl

# Copy the initiation script into the container
COPY --chmod=755 initiate-replica.sh /initiate-replica.sh

# Set the entrypoint to the initiation script
ENTRYPOINT ["/bin/bash", "/initiate-replica.sh"]