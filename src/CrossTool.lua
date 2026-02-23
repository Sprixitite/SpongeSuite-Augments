local CrossTool = {}

local _toolDB = {}

function CrossTool.Register(name, fn)
	if _toolDB[name] ~= nil then
		error(`CrossTool : Attempt to define {name} twice!`)
	end
	_toolDB[name] = fn
end

function CrossTool.TryRun(name, ...)
	if _toolDB[name] == nil then return end
	_toolDB[name](...)
end

return CrossTool