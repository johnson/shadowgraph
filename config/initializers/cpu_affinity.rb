require 'inline'

# ruby-inline 做linux的c api调用来限制进程cpu占用
# By Peter Cooper - http://www.rubyinside.com/
# Oodles of inspiration and examples from
# http://www-128.ibm.com/developerworks/linux/library/l-affinity.html
class LinuxScheduler
  inline do |builder|
    builder.include '<sched.h>'
    builder.include '<stdio.h>'
    builder.c '
    int _set_affinity(int cpu_id) {
      cpu_set_t mask;
      __CPU_ZERO(&mask);
      __CPU_SET(cpu_id, &mask);
      if(sched_setaffinity(getpid(), sizeof(mask), &mask ) == -1) {
        printf("WARNING: Could not set CPU Affinity, continuing as-is\n");
        return 0;
      }
      return 1;
    }
    '
  end

  # cpu_id is 0-based, so for core/cpu 1 = 0, etc..
  def self.set_affinity(cpu_id)
    self.new._set_affinity(cpu_id.to_i)
  end
end if RUBY_PLATFORM =~ /Linux/