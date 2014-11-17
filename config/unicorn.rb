worker_processes 4
timeout 30

@app_path = '/home/peter/nginx-unicorn-sinatra'
listen "#{@app_path}/tmp/sockets/unicorn.sock", :backlog => 64
pid "#{@app_path}/tmp/pids/unicorn.pid"
