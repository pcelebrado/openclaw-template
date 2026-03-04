#!/bin/bash
# OpenClaw Local Testing Suite
# Full stack testing without Railway dashboard
# Usage: ./test-local.sh [command]

set -e

# Colors for TUI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WEB_PORT=${WEB_PORT:-3000}
CORE_PORT=${CORE_PORT:-8080}
MONGO_PORT=${MONGO_PORT:-27017}
SFTP_PORT=${SFTP_PORT:-2022}

# BuildKit setup
BUILDKIT_CONTAINER="buildkit-openclaw"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

header() {
    echo ""
    echo "======================================"
    echo "$1"
    echo "======================================"
}

check_prerequisites() {
    header "CHECKING PREREQUISITES"
    
    local missing=()
    
    if ! command -v docker &> /dev/null; then
        missing+=("docker")
    fi
    
    if ! command -v railpack &> /dev/null; then
        log_warn "Railpack not found. Install with: curl -sSL https://railpack.com/install.sh | sh"
        missing+=("railpack")
    else
        log_success "Railpack: $(railpack --version)"
    fi
    
    if ! command -v node &> /dev/null; then
        missing+=("node")
    else
        log_success "Node: $(node --version)"
    fi
    
    if ! command -v npm &> /dev/null; then
        missing+=("npm")
    else
        log_success "npm: $(npm --version)"
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing: ${missing[*]}"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

setup_buildkit() {
    header "SETTING UP BUILDKIT"
    
    if docker ps | grep -q "$BUILDKIT_CONTAINER"; then
        log_success "BuildKit already running"
    else
        log_info "Starting BuildKit container..."
        docker run --rm --privileged -d \
            --name "$BUILDKIT_CONTAINER" \
            --publish 1234:1234 \
            moby/buildkit:latest || {
            log_error "Failed to start BuildKit"
            exit 1
        }
        log_success "BuildKit started"
    fi
    
    export BUILDKIT_HOST="docker-container://$BUILDKIT_CONTAINER"
    log_info "BUILDKIT_HOST=$BUILDKIT_HOST"
}

test_railpack_web() {
    header "TESTING RAILPACK: WEB SERVICE"
    
    cd services/web
    
    log_info "Generating build plan..."
    railpack plan . --out ../../.test/web-plan.json 2>&1 | tee ../../.test/web-plan.log
    
    if [ -f ../../.test/web-plan.json ]; then
        log_success "Build plan generated"
        log_info "Plan location: .test/web-plan.json"
        
        # Check for critical elements
        if grep -q "startCommand" ../../.test/web-plan.json; then
            log_success "Start command detected in plan"
        else
            log_error "No start command in plan!"
        fi
        
        if grep -q "PORT" ../../.test/web-plan.json; then
            log_success "PORT variable detected"
        else
            log_warn "PORT variable not found in plan"
        fi
    else
        log_error "Build plan generation failed"
        return 1
    fi
    
    log_info "Building image (this may take a while)..."
    railpack build . --name openclaw-web:test 2>&1 | tee ../../.test/web-build.log
    
    if docker images | grep -q "openclaw-web"; then
        log_success "Web image built successfully"
        docker images | grep openclaw-web | head -1
    else
        log_error "Web image build failed"
        return 1
    fi
    
    cd ../..
}

test_railpack_core() {
    header "TESTING RAILPACK: CORE SERVICE"
    
    cd services/core
    
    log_info "Generating build plan..."
    railpack plan . --out ../../.test/core-plan.json 2>&1 | tee ../../.test/core-plan.log
    
    if [ -f ../../.test/core-plan.json ]; then
        log_success "Build plan generated"
        log_info "Plan location: .test/core-plan.json"
        
        if grep -q "startCommand" ../../.test/core-plan.json; then
            log_success "Start command detected in plan"
        else
            log_error "No start command in plan!"
        fi
    else
        log_error "Build plan generation failed"
        return 1
    fi
    
    log_info "Building image (this may take a while)..."
    railpack build . --name openclaw-core:test 2>&1 | tee ../../.test/core-build.log
    
    if docker images | grep -q "openclaw-core"; then
        log_success "Core image built successfully"
        docker images | grep openclaw-core | head -1
    else
        log_error "Core image build failed"
        return 1
    fi
    
    cd ../..
}

test_dockerfile_web() {
    header "TESTING DOCKERFILE: WEB SERVICE"
    
    cd services/web
    
    log_info "Building with Docker..."
    docker build -t openclaw-web:docker . 2>&1 | tee ../../.test/web-docker.log
    
    if docker images | grep -q "openclaw-web.*docker"; then
        log_success "Web Dockerfile build successful"
    else
        log_error "Web Dockerfile build failed"
        return 1
    fi
    
    cd ../..
}

test_dockerfile_core() {
    header "TESTING DOCKERFILE: CORE SERVICE"
    
    cd services/core
    
    log_info "Building with Docker..."
    docker build -t openclaw-core:docker . 2>&1 | tee ../../.test/core-docker.log
    
    if docker images | grep -q "openclaw-core.*docker"; then
        log_success "Core Dockerfile build successful"
    else
        log_error "Core Dockerfile build failed"
        return 1
    fi
    
    cd ../..
}

run_integration_test() {
    header "INTEGRATION TEST: FULL STACK"
    
    # Create test network
    docker network create openclaw-test 2>/dev/null || true
    
    # Start Core service
    log_info "Starting Core service..."
    docker run -d \
        --name openclaw-core-test \
        --network openclaw-test \
        -p $CORE_PORT:8080 \
        -p $MONGO_PORT:27017 \
        -p $SFTP_PORT:2022 \
        -e PORT=8080 \
        -e HOSTNAME=0.0.0.0 \
        -e SETUP_PASSWORD=testpassword \
        -e INTERNAL_SERVICE_TOKEN=testtoken \
        openclaw-core:docker 2>&1 | tee .test/core-run.log
    
    sleep 5
    
    # Test Core health
    log_info "Testing Core health..."
    if curl -s http://localhost:$CORE_PORT/setup/healthz > /dev/null 2>&1; then
        log_success "Core healthcheck PASS"
    else
        log_error "Core healthcheck FAIL"
        docker logs openclaw-core-test 2>&1 | tail -20
    fi
    
    # Start Web service
    log_info "Starting Web service..."
    docker run -d \
        --name openclaw-web-test \
        --network openclaw-test \
        -p $WEB_PORT:3000 \
        -e PORT=3000 \
        -e HOSTNAME=0.0.0.0 \
        -e INTERNAL_CORE_BASE_URL=http://openclaw-core-test:8080 \
        -e INTERNAL_SERVICE_TOKEN=testtoken \
        -e AUTH_SECRET=testsecret \
        openclaw-web:docker 2>&1 | tee .test/web-run.log
    
    sleep 3
    
    # Test Web health
    log_info "Testing Web health..."
    if curl -s http://localhost:$WEB_PORT/api/health > /dev/null 2>&1; then
        log_success "Web healthcheck PASS"
    else
        log_error "Web healthcheck FAIL"
        docker logs openclaw-web-test 2>&1 | tail -20
    fi
    
    # Service-to-service test
    log_info "Testing service communication..."
    if docker exec openclaw-web-test curl -s http://openclaw-core-test:8080/setup/healthz > /dev/null 2>&1; then
        log_success "Web → Core communication PASS"
    else
        log_error "Web → Core communication FAIL"
    fi
    
    # Cleanup
    log_info "Cleaning up test containers..."
    docker stop openclaw-web-test openclaw-core-test 2>/dev/null || true
    docker rm openclaw-web-test openclaw-core-test 2>/dev/null || true
}

show_build_comparison() {
    header "BUILD COMPARISON"
    
    echo ""
    echo "Railpack Images:"
    docker images | grep openclaw | grep ":test" || echo "  None built"
    
    echo ""
    echo "Dockerfile Images:"
    docker images | grep openclaw | grep ":docker" || echo "  None built"
    
    echo ""
    echo "Image Sizes:"
    docker images | grep openclaw | awk '{printf "  %-20s %s\n", $1":"$2, $7}'
}

show_logs() {
    header "RECENT LOGS"
    
    if [ -d .test ]; then
        echo ""
        echo "Available logs:"
        ls -lh .test/ 2>/dev/null || echo "  No logs yet"
    fi
}

cleanup() {
    header "CLEANUP"
    
    log_info "Stopping BuildKit..."
    docker stop "$BUILDKIT_CONTAINER" 2>/dev/null || true
    docker rm "$BUILDKIT_CONTAINER" 2>/dev/null || true
    
    log_info "Removing test containers..."
    docker stop openclaw-web-test openclaw-core-test 2>/dev/null || true
    docker rm openclaw-web-test openclaw-core-test 2>/dev/null || true
    
    log_info "Removing test network..."
    docker network rm openclaw-test 2>/dev/null || true
    
    log_success "Cleanup complete"
}

# Main menu
case "${1:-menu}" in
    check|prereq)
        check_prerequisites
        ;;
    setup)
        setup_buildkit
        ;;
    railpack-web|rp-web)
        mkdir -p .test
        setup_buildkit
        test_railpack_web
        ;;
    railpack-core|rp-core)
        mkdir -p .test
        setup_buildkit
        test_railpack_core
        ;;
    railpack-all|rp-all)
        mkdir -p .test
        check_prerequisites
        setup_buildkit
        test_railpack_web
        test_railpack_core
        show_build_comparison
        ;;
    docker-web|df-web)
        mkdir -p .test
        test_dockerfile_web
        ;;
    docker-core|df-core)
        mkdir -p .test
        test_dockerfile_core
        ;;
    docker-all|df-all)
        mkdir -p .test
        test_dockerfile_web
        test_dockerfile_core
        show_build_comparison
        ;;
    integration|test)
        mkdir -p .test
        run_integration_test
        ;;
    full|all)
        mkdir -p .test
        check_prerequisites
        setup_buildkit
        test_railpack_web
        test_railpack_core
        test_dockerfile_web
        test_dockerfile_core
        show_build_comparison
        run_integration_test
        ;;
    compare)
        show_build_comparison
        ;;
    logs)
        show_logs
        ;;
    clean|cleanup)
        cleanup
        ;;
    help|--help|-h|*)
        echo "OpenClaw Local Testing Suite"
        echo ""
        echo "Usage: ./test-local.sh [command]"
        echo ""
        echo "Commands:"
        echo "  check              - Check prerequisites"
        echo "  setup              - Setup BuildKit"
        echo "  railpack-web       - Test Railpack build for Web"
        echo "  railpack-core      - Test Railpack build for Core"
        echo "  railpack-all       - Test Railpack for both services"
        echo "  docker-web         - Test Dockerfile build for Web"
        echo "  docker-core        - Test Dockerfile build for Core"
        echo "  docker-all         - Test Dockerfile for both services"
        echo "  integration        - Run integration tests"
        echo "  full, all          - Run everything"
        echo "  compare            - Compare build sizes"
        echo "  logs               - Show available logs"
        echo "  clean              - Cleanup containers"
        echo "  help               - Show this help"
        echo ""
        echo "Environment Variables:"
        echo "  WEB_PORT=$WEB_PORT    - Web service port"
        echo "  CORE_PORT=$CORE_PORT   - Core service port"
        echo "  MONGO_PORT=$MONGO_PORT  - MongoDB port"
        echo "  SFTP_PORT=$SFTP_PORT   - SFTP port"
        ;;
esac
