#アプリケーションサーバの性能を決定する
worker_processes 1

#アプリケーションの設置されているディレクトリを指定
working_directory "/var/www/SQU-App/current"

#Unicornの起動に必要なファイルの設置場所を指定
pid "/var/www/SQU-App/shared/tmp/pids/unicorn.pid"

#ポート番号を指定
listen "/var/www/SQU-App/shared/tmp/sockets/unicorn.sock", backlog: 64

#エラーのログを記録するファイルを指定
stderr_path "/var/www/SQU-App/shared/log/unicorn.stderr.log"

#通常のログを記録するファイルを指定
stdout_path "/var/www/SQU-App/shared/log/unicorn.stdout.log"

#Railsアプリケーションの応答を待つ上限時間を設定
timeout 60

#以下は応用的な設定なので説明は割愛

preload_app true
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

check_client_connection false

run_once = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  if run_once
    run_once = false # prevent from firing again
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH => e
      logger.error e
    end
  end
end

after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end