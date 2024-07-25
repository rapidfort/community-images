#!/bin/bash

set -x
set -e

GITLAB_DIR="/srv/gitlab"
RAILS_ENV="production"
LOG_FILE="/tmp/gitlab_sidekiq_container_test_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1"
    exit 1
}

run_command() {
    if ! "$@" >> "$LOG_FILE" 2>&1; then
        error "Failed to run command: $*"
    fi
}

check_environment() {
    log "Checking environment..."
    if [ ! -d "$GITLAB_DIR" ]; then
        error "GitLab directory $GITLAB_DIR not found"
    fi
    if [ ! -f "$GITLAB_DIR/config/database.yml" ]; then
        error "database.yml not found in $GITLAB_DIR/config/"
    fi
}

run_sidekiq() {
    log "Starting Sidekiq process..."
    bundle exec sidekiq -e $RAILS_ENV -C $GITLAB_DIR/config/sidekiq_queues.yml &
    SIDEKIQ_PID=$!
    sleep 15
    if ! ps -p $SIDEKIQ_PID > /dev/null; then
        error "Sidekiq process failed to start or terminated prematurely"
    fi
    log "Sidekiq process started successfully"
    kill $SIDEKIQ_PID
    wait $SIDEKIQ_PID 2>/dev/null || true
    log "Stopped Sidekiq process"
}

check_rails_environment() {
    log "Checking Rails environment..."
    run_command bundle exec rails runner "puts Rails.env" RAILS_ENV=$RAILS_ENV
}

run_rake_tasks() {
    log "Running GitLab Rake tasks..."
    rake_tasks=(
        "gitlab:env:info"
        "gitlab:sidekiq:check"
        "gitlab:gitaly:check"
        "gitlab:incoming_email:check"
        "gitlab:lfs:check"
        "gitlab:artifacts:check"
        "gitlab:ldap:check"
        "gitlab:uploads:check"
        "zeitwerk:check"
    )

    for task in "${rake_tasks[@]}"; do
        log "Running task: $task"
        run_command rake $task RAILS_ENV=$RAILS_ENV
    done
}


enqueue_test_jobs() {
    log "Enqueuing test Sidekiq jobs..."
    run_command bundle exec rails runner "
                ProjectCacheWorker.perform_async(1)
                PruneOldEventsWorker.perform_async
                RemoveExpiredMembersWorker.perform_async
                ComplexUserActivityWorker.perform_async
                " RAILS_ENV=$RAILS_ENV
}

check_sidekiq_queues() {
    log "Checking Sidekiq queues..."
    run_command bundle exec rails runner '
        Sidekiq::Queue.all.each do |queue|
            puts "Queue: #{queue.name}, size: #{queue.size}"
        end
    ' RAILS_ENV=$RAILS_ENV
}

check_redis_connection() {
    log "Checking Redis connection..."
    run_command bundle exec rails runner "
        require 'redis'
        require 'gitlab/redis'

        begin
            Gitlab::Redis::SharedState.with do |redis|
            puts \"Redis connection successful: #{redis.ping == 'PONG'}\"
            end
        rescue => e
            puts \"Redis connection failed: #{e.message}\"
        end
        " RAILS_ENV=$RAILS_ENV
}

run_inbuilt_scripts() {
    run_command ../../scripts/healthcheck
}

main() {
    log "Starting GitLab Sidekiq container functionality test"

    cd $GITLAB_DIR || error "Failed to change directory to $GITLAB_DIR"

    run_inbuilt_scripts
    check_environment
    check_rails_environment
    run_sidekiq
    run_rake_tasks
    check_redis_connection
    enqueue_test_jobs
    check_sidekiq_queues

    log "Container test completed successfully. Log file: $LOG_FILE"
}

main