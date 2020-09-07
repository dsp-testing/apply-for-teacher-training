module HostingEnvironment
  TEST_ENVIRONMENTS = %w[development test qa review].freeze

  def self.application_url
    if Rails.env.production?
      "https://#{hostname}"
    else
      "http://localhost:#{ENV.fetch('PORT', 3000)}"
    end
  end

  def self.authorised_hosts
    hosts = ENV.fetch('AUTHORISED_HOSTS').split(',').map(&:strip)
    hosts.prepend "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV['HEROKU_APP_NAME']
    hosts
  end

  def self.hostname
    ENV.fetch('CUSTOM_HOSTNAME', authorised_hosts.first)
  end

  def self.phase
    if production?
      'beta'
    else
      environment_name
    end
  end

  def self.environment_name
    ENV.fetch('HOSTING_ENVIRONMENT_NAME', 'unknown-environment')
  end

  def self.review?
    environment_name == 'review'
  end

  def self.qa?
    environment_name == 'qa'
  end

  def self.production?
    environment_name == 'production'
  end

  def self.sandbox_mode?
    ENV.fetch('SANDBOX', 'false') == 'true'
  end

  def self.test_environment?
    TEST_ENVIRONMENTS.include?(HostingEnvironment.environment_name)
  end
end
