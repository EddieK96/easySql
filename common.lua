-- Sources: https://www.tutorialspoint.com/how-to-implement-a-queue-in-lua-programming
-- https://gist.github.com/FreeBirdLjj/6303864?permalink_comment_id=3581295


function try (func, except, finally)
	local _error = nil
	if (func) and (except == nil) and (finally == nil) then
		if not xpcall(func, function(err) 
			_error = err
		end) then
			error("UNCAUGHT ERROR: " .. _error, 2)
		end
	end
	
	if (func) and (except) and (finally == nil) then
		xpcall(func, function(err) 
			_error = err
			except(err)
		end)
	end
	
	if (func) and (except == nil) and (finally) then
		if xpcall(func, function(err) 
			_error = err
			finally(err)
		end) then
			finally()
		else
			error("UNCAUGHT ERROR: " .. _error, 2)
		end
	end
	
	if (func) and (except) and (finally) then
		if xpcall(func, function(err) 
			_error = err
			except(err)
			finally(err)
		end) then
			finally()
		end
	end
end

function switch(v, cases)
	local f = cases[v] -- get case function by key
	if(f) then -- if function exists for case...
		f() -- execute function
	else -- for case default
		cases.default()
	end
end

--[[ Usage/Example:
switch(9, {
	[1] = function ()
		print "Case 1."
	end,
	[2] = function ()
		print "Case 2."
	end,
	[3] = function ()
		print "Case 3."
	end,
	default = function ()
		print "Default"
	end,
})
--]]

function awaitInit (l, cb)
	if cb == nil then
		try(function()	
			Citizen.Wait(0)
			while (l == nil) or (l.initialized == nil) or (l.initialized == false) do
				Citizen.Wait(0)
			end
		end)
	else
		Citizen.CreateThread(function ()
			while (l == nil) or (l.initialized == nil) or (l.initialized == false) do
				Citizen.Wait(0)
			end
			cb()
		end)
	end
end

function cout (text)
	if Config and Config.debugMode then
		Citizen.Trace(text .. "\n")
	end
end

function cloneTable(t) --from ESX/common/tables
	if type(t) ~= 'table' then return t end

	local meta = getmetatable(t)
	local target = {}

	for k,v in pairs(t) do
		if type(v) == 'table' then
			target[k] = cloneTable(v)
		else
			target[k] = v
		end
	end

	setmetatable(target, meta)

	return target
end

queue = {}
function queue.insert(q, val)
	cout("queue.insert: Inserted value.")
	if q.size == nil then
		q.size = 0
	end
	if q.last == nil then
		q.last = -1
	end
	if q.first == nil then
		q.first = 0
	end
	if q.data == nil then
		q.data = {}
	end
   q.last = q.last + 1
   q.data[q.last] = val
   q.size = q.size + 1
end

function queue.remove(q)
   local rval = -1
   if q.size == nil then
		q.size = 0
	end
   if q.last == nil then
		q.last = -1
	end
	if q.first == nil then
		q.first = 0
	end
   if q.data == nil then
		q.data = {}
	end
   if ((q == {}) or (q.first == nil) or (q.last == nil)) or (q.first > q.last) then
	  rval = -1
   else
		cout("queue.insert: Pulled value.")
	  rval = q.data[q.first]
	  q.data[q.first] = nil
	  q.first = q.first + 1
   end
   q.size = q.size - 1
   return rval
end
-- end

function tableLength (t)
	count = 0
	for k,v in pairs(t) do count = count + 1 end
	return count
end

function sharedObjectsLength ()
	sharedObjectsLength = tableLength(sharedObjects)
end
	
function boolToInt (b)
	if b then
		return 1
	else
		return 0
	end
end

function boolToStr (b)
	if b then
		return "true"
	else
		return "false"
	end
end




