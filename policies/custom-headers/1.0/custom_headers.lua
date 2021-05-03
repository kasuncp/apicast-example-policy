local ipairs = ipairs
local insert = table.insert
local string = string

local jwt = require 'resty.jwt'

local _M = require('apicast.policy').new('Custom headers policy', '1.0')

local auth_header = 'Authorization'
local user_header = 'randoli-user'

local new = _M.new

local function get_token_from_header(header)
  chunks = {}
  for chunk in string.gmatch(header, "%S+") do
    chunks[#chunks+1] = chunk
  end

  if #chunks > 1 and chunks[2] then
    return chunks[2]
  end

  return nil
end

function _M.new(config)
  local self = new(config)

  return self
end

function _M:init()
  -- do work when nginx master process starts
end

function _M:init_worker()
  -- do work when nginx worker process is forked from master
end

function _M:rewrite()
  local req_headers = ngx.req.get_headers() or {}
  
  if req_headers[auth_header] then
    -- 1. Extract only the token from the header
    local token = get_token_from_header(req_headers[auth_header])

    -- 2. Decode the JWT token and convert it to json
    if token then
      local jwt_obj = jwt:load_jwt(token)

      if jwt_obj and jwt_obj['payload'] and jwt_obj['payload']['preferred_username'] then
        ngx.req.set_header(user_header, jwt_obj['payload']['preferred_username'])
      end
    end
    
  end

end

function _M:access()
  -- ability to deny the request before it is sent upstream
end

function _M:content()
  -- can create content instead of connecting to upstream
end

function _M:post_action()
  -- do something after the response was sent to the client
end

function _M:header_filter()
  -- can change response headers
end

function _M:body_filter()
  -- can read and change response body
  -- https://github.com/openresty/lua-nginx-module/blob/master/README.markdown#body_filter_by_lua
end

function _M:log()
  -- can do extra logging
end

function _M:balancer()
  -- use for example require('resty.balancer.round_robin').call to do load balancing
end

return _M
