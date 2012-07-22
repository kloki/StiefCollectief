function inlist(item,list)
   answer=false
   for _,i in pairs(list) do
      if i==item then answer=true break end
   end

return answer
end


function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
       if type(object) ~= "table" then
return object
       elseif lookup_table[object] then
return lookup_table[object]
       end
       local new_table = {}
       lookup_table[object] = new_table
       for index, value in pairs(object) do
new_table[_copy(index)] = _copy(value)
       end
       return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end


--like python split
function string:split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField=1 nStart=1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
end

--like python strip
function string:strip(chr)
    local s = ""
    for g in self:gmatch( "[^"..chr.."]" ) do
 	s = s .. g
    end
    return s
end