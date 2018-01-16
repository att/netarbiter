# Prometheus HOWTO
Author: Hee Won Lee <knowpd@research.att.com>  

### Jobs and instances

- Instances
   * An endpoint you can scrape 
   * Usually corresponding to a single process. 
- Job
   * A collection of instances with the same purpose
   * Example: a process replicated for scalability or reliability
   ```
   job: api-server
     instance 1: 1.2.3.4:5670
     instance 2: 1.2.3.4:5671
     instance 3: 5.6.7.8:5670
     instance 4: 5.6.7.8:5671
   ```

### Querying
Refer to <https://prometheus.io/docs/prometheus/latest/querying/examples>


