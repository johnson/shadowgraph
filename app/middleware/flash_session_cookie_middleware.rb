require 'rack/utils'
# 用于flash提交的post请求查询参数附带上的cookie信息转换为http头cookie信息，
# 并提交给rack进一步给rails app处理
class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      # params = ::Rack::Utils.parse_query(env['QUERY_STRING']) #老版本的rack
      params = Rack::Request.new(env).params
      unless params[@session_key].nil?
        env['HTTP_COOKIE'] = "#{@session_key}=#{params[@session_key]}".freeze
      end
    end
    
    @app.call(env)
  end
end