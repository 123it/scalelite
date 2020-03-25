# frozen_string_literal: true

class HealthCheckController < ApplicationController
  def all
    @cache_expire = 10.seconds

    begin
      cache_check
      database_check
    rescue StandardError => e
      render(plain: "Health Check Failure: #{e}")
    end

    render status: 200, 'success'
  end

  private

  def cache_check
    raise 'Unable to write to cache' unless Rails.cache.write('__health_check_cache_write__', 'true', expires_in: @cache_expire)
    raise 'Unable to read from cache' unless Rails.cache.read('__health_check_cache_write__') == 'true'
  end

  def database_check
    if defined?(ActiveRecord)
      raise 'Database not responding' unless ActiveRecord::Migrator.current_version
    end
    raise 'Pending migrations' unless ActiveRecord::Migration.check_pending!.nil?
  end
end
