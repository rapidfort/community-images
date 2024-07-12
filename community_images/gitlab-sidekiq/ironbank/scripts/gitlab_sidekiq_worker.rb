class ComplexUserActivityWorker
    include ApplicationWorker
  
    feature_category :users
    idempotent!
  
    def perform(user_id = nil, activity_type = nil, timestamp = nil)
      @user = user_id ? User.find_by(id: user_id) : ensure_test_user
      @activity_type = activity_type || ACTIVITY_TYPES.sample
      @timestamp = timestamp || Time.current
  
      process_activity
      update_user_statistics
      enqueue_follow_up_jobs
      record_unique_action
    end
  
    private
  
    ACTIVITY_TYPES = %w[login commit merge_request issue_comment].freeze
  
    def ensure_test_user
      User.find_or_create_by!(email: 'test_user@example.com') do |user|
        user.name = 'Test User'
        user.password = 'password123'
        user.password_confirmation = 'password123'
      end
    end
  
    def process_activity
      Gitlab::AppLogger.info "Processing #{@activity_type} for user #{@user.id}"
      
      # Simulate processing delay
      Gitlab::Application.load_runner.throttle(0.5)
  
      # Record activity in database
      UserActivity.create!(user: @user, activity_type: @activity_type, timestamp: @timestamp)
    end
  
    def update_user_statistics
      Gitlab::AppLogger.info "Updating statistics for user #{@user.id}"
      
      UserStatistics.transaction do
        stats = @user.statistics || @user.create_statistics
        stats.increment!("#{@activity_type}_count")
        stats.update!(last_activity_at: Time.current)
      end
    end
  
    def enqueue_follow_up_jobs
      Gitlab::AppLogger.info "Enqueuing follow-up jobs for user #{@user.id}"
      
      case @activity_type
      when 'login'
        SecurityAuditWorker.perform_async(@user.id, 'login')
      when 'commit'
        UpdateProjectStatisticsWorker.perform_async(@user.id)
      when 'merge_request'
        NotifyTeamMembersWorker.perform_async(@user.id, 'merge_request')
      when 'issue_comment'
        UpdateIssueMetricsWorker.perform_async(@user.id)
      end
    end
  
    def record_unique_action
      Gitlab::UsageDataCounters::HLLRedisCounter.track_event("user_#{@activity_type}", values: @user.id)
    end
  end