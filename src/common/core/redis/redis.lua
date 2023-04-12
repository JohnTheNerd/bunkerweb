local class			= require "middleclass"
local plugin		= require "bunkerweb.plugin"
local logger		= require "bunkerweb.logger"
local utils			= require "bunkerweb.utils"
local clusterstore	= require "bunkerweb.clusterstore"

local redis = class("redis", plugin)

function redis:new()
	plugin.new(self, "redis")
	-- Store variable for later use
	local use_redis, err = utils.get_variable("USE_REDIS", false)
	if use_redis == nil then
		return self:ret(false, "can't check USE_REDIS variable : " .. err)
	end
	self.use_redis = use_redis == "yes"
	return self:ret(true, "success")
end

function redis:init()
	-- Check if init is needed
	if not self.use_redis then
		return self:ret(true, "redis not used")
	end
	-- Check redis connection
	local ok, err = clusterstore:connect()
	if not ok then
		return self:ret(false, "redis connect error : " .. err)
	end
	local ok, err = clusterstore:call("ping")
	clusterstore:close()
	if err then
		return self:ret(false, "error while sending ping command : " .. err)
	end
	if not ok then
		return self:ret(false, "ping command failed")
	end
	return self:ret(true, "redis ping successful")
end

return redis