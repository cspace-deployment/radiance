#
# hasty god script to monitor the ucb apps
#
# pahma 3000
# ucjeps 3001
# bampfa 3002
# botgarden 3003
# cinefiles 3004
#
# TODO: mebbe consider make this whole thing one loop...
#

RAILS_ROOT = "/home/bitnami/projects/pahma"
PORT = "3000"
TENANT = "pahma"

God.watch do |w|
  w.name = "#{TENANT}"

  #w.pid_file = File.join(RAILS_ROOT, "log/rails.pid")
  w.pid_file = "#{RAILS_ROOT}/log/rails.pid"

  w.dir = "#{RAILS_ROOT}"
  w.log = "#{RAILS_ROOT}/log/god.log"
  w.start = "passenger start -d -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.stop = "passenger stop -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.restart = "passenger restart -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  w.keepalive
  w.interval = 60.seconds
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

RAILS_ROOT = "/home/bitnami/projects/ucjeps"
PORT = "3001"
TENANT = "ucjeps"

God.watch do |w|
  w.name = "#{TENANT}"

  #w.pid_file = File.join(RAILS_ROOT, "log/rails.pid")
  w.pid_file = "#{RAILS_ROOT}/log/rails.pid"

  w.dir = "#{RAILS_ROOT}"
  w.log = "#{RAILS_ROOT}/log/god.log"
  w.start = "passenger start -d -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.stop = "passenger stop -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.restart = "passenger restart -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  w.keepalive
  w.interval = 60.seconds
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

RAILS_ROOT = "/home/bitnami/projects/bampfa"
PORT = "3002"
TENANT = "bampfa"

God.watch do |w|
  w.name = "#{TENANT}"

  #w.pid_file = File.join(RAILS_ROOT, "log/rails.pid")
  w.pid_file = "#{RAILS_ROOT}/log/rails.pid"

  w.dir = "#{RAILS_ROOT}"
  w.log = "#{RAILS_ROOT}/log/god.log"
  w.start = "passenger start -d -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.stop = "passenger stop -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.restart = "passenger restart -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  w.keepalive
  w.interval = 60.seconds
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

RAILS_ROOT = "/home/bitnami/projects/botgarden"
PORT = "3003"
TENANT = "botgarden"

God.watch do |w|
  w.name = "#{TENANT}"

  #w.pid_file = File.join(RAILS_ROOT, "log/rails.pid")
  w.pid_file = "#{RAILS_ROOT}/log/rails.pid"

  w.dir = "#{RAILS_ROOT}"
  w.log = "#{RAILS_ROOT}/log/god.log"
  w.start = "passenger start -d -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.stop = "passenger stop -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.restart = "passenger restart -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  w.keepalive
  w.interval = 60.seconds
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

RAILS_ROOT = "/home/bitnami/projects/cinefiles"
PORT = "3004"
TENANT = "botgarden"

God.watch do |w|
  w.name = "#{TENANT}"

  #w.pid_file = File.join(RAILS_ROOT, "log/rails.pid")
  w.pid_file = "#{RAILS_ROOT}/log/rails.pid"

  w.dir = "#{RAILS_ROOT}"
  w.log = "#{RAILS_ROOT}/log/god.log"
  w.start = "passenger start -d -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.stop = "passenger stop -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  #w.restart = "passenger restart -p #{PORT} -b 0.0.0.0 -P #{RAILS_ROOT}/log/rails.pid "
  w.keepalive
  w.interval = 60.seconds
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
