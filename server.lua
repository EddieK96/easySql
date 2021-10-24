-- Example Columns:
	--`license` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
	--`money` int(11) DEFAULT NULL,
	
local clock = os.clock
local function sleep(n)
	local t0 = clock()
	while clock() - t0 <= n do end
end

advsql = {}
advsql.ready = false

print("initializing...")
while MySQL == nil do
	sleep(0.001)
end
MySQL.ready(function ()
	function alterTable (tableName, k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey, operation, callback, insertAft)
		local strFetch = "ALTER TABLE `" .. tableName .. "` "
		local valueList = {}
		local primaryKey = ""
		local after = insertAft
		local ordered = false
		
		if after == nil then
			ordered = false
		else
			ordered = true
		end
		
		if (not(k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey == nil)) and not (operation == nil) then
			if operation == "ADD COLUMN" then
				for k,v in pairs(k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey) do
					
					-- Type length parameter case switch
					if (not(v.dataType == nil)) and (not(v.length == nil)) and (not(v.dataType == "longtext")) and (not(v.dataType == "int")) then
						strFetch = strFetch .. " ADD COLUMN IF NOT EXISTS `" .. k .. "` " .. v.dataType .. "(" .. tostring(v.length) .. ") "
					elseif (not(v.dataType == nil)) and (not(v.length == nil)) and (v.dataType == "longtext" or v.dataType == "int") then
						strFetch = strFetch .. " ADD COLUMN IF NOT EXISTS `" .. k .. "` " .. v.dataType .. " "
					else
						return false
					end
					
					-- Default value case switch
					if (not(v.dataType == nil)) then
						if v.dataType == "varchar" then
							if v.defaultValue == nil then
								strFetch = strFetch .. "NULL "
							elseif (v.defaultValue == "NOT NULL") or (v.defaultValue == "NULL DEFAULT ''") then
								strFetch = strFetch .. "NULL DEFAULT '' "
							else
								valueList["@" .. k] = v.defaultValue
								strFetch = strFetch .. "NULL DEFAULT " .. "@" .. k .. " "
							end
						elseif v.dataType == "longtext" then
							strFetch = strFetch .. "NULL "

						elseif v.dataType == "int" then
							if v.defaultValue == nil then
								strFetch = strFetch .. "NULL "
							elseif (v.defaultValue == "NOT NULL") or (v.defaultValue == 0) then
								strFetch = strFetch .. "NULL DEFAULT 0 "
							else
								valueList["@" .. k] = v.defaultValue
								strFetch = strFetch .. "NULL DEFAULT " .. "@" .. k .. " "
							end
						else
							if v.defaultValue == nil then
								strFetch = strFetch .. "NULL "
							elseif (v.defaultValue == "NOT NULL") or (v.defaultValue == 0) then
								strFetch = strFetch .. "NULL DEFAULT 0 "
							else
								valueList["@" .. k] = v.defaultValue
								strFetch = strFetch .. "NULL DEFAULT " .. "@" .. k .. " "
							end
						end
					else
						return false
					end
					if ordered then
						strFetch = strFetch .. "AFTER " .. "`" .. after .. "`, "
					else	
						strFetch = strFetch .. ", "
					end
				end
			else
				return false
			end
			
			-- Cut off extra comma
			if (not (strFetch == nil)) and string.len(strFetch) >= 2 then
				strFetch = string.sub(strFetch,1, string.len(strFetch) - 2)
			else
				return false
			end
			strFetch = strFetch .. "; "
			MySQL.Async.fetchAll(strFetch, valueList, callback)
			return true
		else
			return false
		end
	end
	
	function dropTable(tableName, callback)
		if not(tableName == nil) then
			local str_fetch = "DROP TABLE IF EXISTS `" .. tableName .. "`"
			print(str_fetch)
			MySQL.Async.fetchAll(str_fetch, {}, callback)
			return true
		else
			return false
		end
	end
	
	function update (tableName, k_columnName_v_value ,where ,callback)
		if (not(tableName == nil)) and (not(k_columnName_v_value == nil)) and (not(where == nil)) then
			local str_fetch = " UPDATE " .. tableName .. " SET "
			local placeholders = {}
			for k,v in pairs(k_columnName_v_value) do
				str_fetch = str_fetch .. k .. " = @" .. k .. ", "
				placeholders["@" .. k] = v
			end
			if (not (str_fetch == nil)) and string.len(str_fetch) >= 2 then
				str_fetch = string.sub(str_fetch,1, string.len(str_fetch) - 2)
			else
				return false
			end
			
			str_fetch = str_fetch .. " WHERE " .. where
				
			print(str_fetch)

			MySQL.Async.fetchAll(str_fetch, placeholders, callback)
			return true
		else
			return false
		end
	end
	
	function deleteRow (tableName, where ,callback)
		if not(tableName == nil) then
			local str_fetch = " DELETE FROM " .. tableName .. " WHERE " .. where
			print(str_fetch)

			MySQL.Async.fetchAll(str_fetch, {}, callback)
			return true
		else
			return false
		end
	end
	
	function createTableIfNotExists (tableName, k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey ,callback)
		local strFetch = "CREATE TABLE IF NOT EXISTS `" .. tableName .. "` ("
		local valueList = {}
		local primaryKey = ""
		
		for k,v in pairs(k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey) do
			if (not(v.dataType == nil)) and not (v.length == nil) then
				strFetch = strFetch .. "`" .. k .. "` ".. v.dataType .. "(" .. tostring(v.length) .. ") "
			elseif (v.length == nil) then
				strFetch = strFetch .. "`" .. k .. "` ".. v.dataType .. " "
			else
				return false
			end
			
			if (not(v.isPrimaryKey == nil)) and v.isPrimaryKey then
				primaryKey = k
			end
			
			if (not(v.dataType == nil)) then
				if v.dataType == "varchar" then
					strFetch = strFetch .. "COLLATE utf8mb4_bin "
					if v.defaultValue == nil then
						strFetch = strFetch .. "DEFAULT NULL, "
					elseif v.defaultValue == "NOT NULL" then
						strFetch = strFetch .. "NOT NULL, "
					else
						valueList["@" .. k] = v.defaultValue
						strFetch = strFetch .. "DEFAULT " .. "@" .. k .. ", "
					end
				else
					if v.defaultValue == nil then
						strFetch = strFetch .. "DEFAULT NULL, "
					elseif v.defaultValue == "NOT NULL" then
						strFetch = strFetch .. "NOT NULL, "
					else
						valueList["@" .. k] = v.defaultValue
						strFetch = strFetch .. "DEFAULT " .. "@" .. k .. ", "
					end
				end
			else
				return false
			end
		end	
		
		if (not (strFetch == nil)) and string.len(strFetch) >= 2 then
			strFetch = string.sub(strFetch,1, string.len(strFetch) - 2)
		else
			return false
		end
		
		strFetch = strFetch .. ", PRIMARY KEY (`" .. primaryKey .. "`) "
		strFetch = strFetch .. ");"
		
		MySQL.Async.fetchAll(strFetch, valueList, callback)
		return true
	end

	function createOrAlterTable (tableName, k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey, callback, insertAfter)
		if not createTableIfNotExists (tableName, k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey ,function (result)
		-- If fetch has been passed...
			print("Attempting to create table...")
			print(json.encode(result)) -- Debugging...
			-- If not successfull -> alter table instead
			if not (result.warningCount == 0) then
				print("Table already exists -> alter instead...")
				if not alterTable(tableName, k_columnName_v_dataType_v_length_v_defaultValue_v_isPrimaryKey, "ADD COLUMN" , callback, insertAfter) then -- If parameters invalid...
					print("[WARNING: 0]: Parameters invalid or data already exists")
				end
			end
		
		end) then -- If parameters invalid...
			print("[ERROR: 1]: Parameters invalid...")
		end
	end

	function insertIntoTable (tableName, k_columnName_v_value, callback)
		local strColumns = ""
		local orderedColumns = {}
		local orderIndex = 0
		if (not(k_columnName_v_value == nil)) then
			for k,v in pairs(k_columnName_v_value) do
				strColumns = strColumns .. k .. ", "
				orderedColumns[orderIndex] = {tableName = k, value = v}
				orderIndex = orderIndex + 1
			end
			
			if (not (strColumns == nil)) and string.len(strColumns) >= 2 then
				strColumns = string.sub(strColumns,1, string.len(strColumns) - 2)
			else
				return false
			end
			
			local str_Fetch = "INSERT INTO " .. tableName .. " (" .. strColumns .. ") "
			local strPlaceholders = "VALUES("

			local valueList = {}
			for i = 0, orderIndex-1, 1 do 
				strPlaceholders = strPlaceholders .. "@" .. orderedColumns[i].tableName .. ", "
				valueList["@" .. orderedColumns[i].tableName] = orderedColumns[i].value
			end
			
			if (not (strPlaceholders == nil)) and string.len(strPlaceholders) >= 2 then
				strPlaceholders = string.sub(strPlaceholders,1, string.len(strPlaceholders) - 2)
			else
				return false
			end
			
			strPlaceholders = strPlaceholders .. ")"
			str_Fetch = str_Fetch .. strPlaceholders
			
			MySQL.Async.fetchAll(str_Fetch, valueList, callback)
			return true
		else
			return false
		end
	end
	
	function getTable (tableName, columns, where)
		local _columns = columns
		local returnItem = nil
		local pass = false
		
		if _columns == nil then
			_columns = "*"
		end
		
		if not(tableName == nil) then
			local str_Fetch = "SELECT " .. _columns .. " FROM " .. tableName
			if not(where == nil) then
				str_Fetch = str_Fetch .. " WHERE " .. where
			end
			
			returnItem = MySQL.Sync.fetchAll(str_Fetch, {})
			
			return returnItem
		end
	end
	
	advsql.ready = true
	function example ()
		-- Creating or altering a table:
			local insertAfter = "identifier"
			local sqlTypeTable = {	
				["identifier"] = {dataType = "varchar", length = 255, defaultValue = "NOT NULL", isPrimaryKey = true}, 
				["license"] = {dataType = "varchar", length = 255, defaultValue = nil, isPrimaryKey = false},
				["bank"] = {dataType = "int", length = 11, defaultValue = 25, isPrimaryKey = false},
				["novel"] = {dataType = "longtext", length = nil, defaultValue = nil, isPrimaryKey = false}
			}				-- Table to create					-- callback
			createOrAlterTable ("exampletable", sqlTypeTable, function(result) 
			
				print(json.encode(result))
				print("Do something...") end
				
			, insertAfter) -- Can be left out aswell as the callback...
			
			createOrAlterTable ("exampletable", sqlTypeTable)
		
		-- Inserting values into a table:
			local valueTable = {
				["identifier"] = "steam:132146460",
				["license"] = "3ead418066eaeeasdade333fc5974da45acc22dfd5",
				["bank"] = 1000000,
				["novel"] = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
			}
			insertIntoTable ("exampletable", valueTable) --...callback,  
			valueTable = {
				["identifier"] = "steam:1615151515",
				["license"] = "3ead418066easfdsfsdDDe333fc5974da45acc22dfd5",
				["bank"] = 0,
				["novel"] = "You are poor... :("
			}
			insertIntoTable ("exampletable", valueTable) --...callback,  
		-- Getting values from a table:
			local values = getTable("exampletable", "identifier, bank")
			print(values)
		-- Deleting values from a table...
		--	dropTable("exampletable", function()
			--	print("Table has been dropped")
		--	end)
		deleteRow ("exampletable", "bank = 0" ,function()
			print("The poor have been deleted.")
		end)
		
		-- Updating a table...
		valueTable = {
				["bank"] = 10000000
			}
		update ("exampletable", valueTable ,"bank > 1000000" ,function()
			print("The rich are now richer.")
		end)
	end
	example ()
end)