class RequestLoggerMiddleware
  def initialize(app)
    @app = app
    @requests = {}
  end

  def call(env)
    request = Rack::Request.new(env)
    ip = request.ip
    path = request.path
    method = request.request_method
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    # Simple in-memory rate limiting: 50 reqs per 1 minutes per IP
    @requests[ip] ||= []
    @requests[ip].reject! { |t| t < Time.now - 60 }  # 5 phút
    @requests[ip] << Time.now

    if @requests[ip].size > 50
      puts "[BLOCKED] #{ip} đã vượt quá giới hạn rate"
      return [429, { "Content-Type" => "text/plain" }, ["Too Many Requests"]]
    end

    # Ghi log request
    Rails.logger.info "[#{time}] #{ip} #{method} #{path}"

    @app.call(env)
  end
end
