group = 'nacc2'

default = DefaultConfig.new(:root => '/home/ubuntu/nacc2')

God.watch do |w|
  name = group + '-passenger'

  default.with(w, :name => name, :group => group)
  w.start    = default.bundle_cmd "passenger start -d -S /tmp/#{group}.sock -e production"
  w.pid_file = "#{default[:root]}/shared/pids/passenger.pid"
   w.start_grace = 15.seconds 
    
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 20.seconds
      c.running = false
    end
  end
 
end
God.watch do |w| 
  name = group + '-delayed_job'
  default.with(w, :name => name, :group => group)
  
  w.start = "RAILS_ENV=production; " +  default.bundle_cmd("#{default[:root]}/current/script/delayed_job start> /tmp/delay_job.out")
  w.stop =  "RAILS_ENV=production; " + default.bundle_cmd("#{default[:root]}/current/script/delayed_job stop")
  w.log = "#{default[:root]}/shared/log/god_delayed_job.log"
  w.start_grace = 15.seconds 
  w.restart_grace = 15.seconds 
  w.pid_file = "#{default[:root]}/shared/pids/delayed_job.pid"
end
