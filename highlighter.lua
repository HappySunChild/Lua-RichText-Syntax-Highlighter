local highlighter = {}

highlighter.lua_globals = {"local", "while", "for", "do", "break", "return", "nil", "not", "true", "false", "if", "elseif", "else", "then", "end", "repeat", "until", "function", "and", "or"}
highlighter.rbx_globals = {"workspace", "game", "script", "math", "string", "table", "wait", "Color3", "BrickColor", "next", "select", "Instance", "Vector2", "Vector3", "UDim2", "Udim", "Enum", "error", "warn", "tick", "loadstring", "_G", "shared", "tonumber", "tostring", "type", "typeof", "in", "pairs", "ipairs", "print", "unpack"}
highlighter.operators = {"=", "-", "+", "*", "/", "^", "%", ";", "~", "(", ")", "[", "]", "{", "}", ",", ".", ":", "<", ">"}

highlighter.number_highlight = "#ffc600"
highlighter.operator_highlight = "#e8d228"
highlighter.lua_highlight = "#f15d5f"
highlighter.rbx_highlight = "#92b4fd"
highlighter.str_highlight = "#38f157"

local function GetHighlight(str)
	if tonumber(str) then
		return number_highlight
	elseif table.find(operators, str) then
		return operator_highlight
	elseif table.find(lua_globals, str) then
		return lua_highlight
	elseif table.find(rbx_globals, str) then
		return rbx_highlight
	end
	
	return false
end

function highlighter:GetHighlight(text, inString)
  local final = ""
	local stringMode = inString or false
	local stringGroup = ""
	local sepGroup = ""
	local wordGroup = ""
	
	text:gsub(".", function(c)
		wordGroup = wordGroup .. c
		
		if not stringMode then
			if c:match("%a") then
				sepGroup = sepGroup .. c
			else
				sepGroup = " "
			end
		end
		
		local letterHighlight = GetHighlight(c)
		local groupHighlight = GetHighlight(wordGroup)
		local sepHighlight = GetHighlight(sepGroup:sub(2))
		
		if c == "\"" then
			stringMode = not stringMode
			
			stringGroup = stringGroup .. c
			
			if not stringMode then
				final = final .. string.format("<font color = \"%s\">%s</font>", str_highlight, stringGroup)
				stringGroup = ""
				wordGroup = ""
			end
		else
			if stringMode then
				stringGroup = stringGroup .. c
			end
		end
		
		if stringMode then return end
		
		if groupHighlight then
			final = final .. string.format("<font color = \"%s\">%s</font>", groupHighlight, wordGroup)
			
			wordGroup = ""
			return
		end
		
		if letterHighlight then
			final = final .. string.format("%s<font color = \"%s\">%s</font>", wordGroup:sub(1, #wordGroup - 1), letterHighlight, c)
			
			sepGroup = ""
			wordGroup = "" -- resert word group to blank string
			return
		end
		
		if sepHighlight then
			final = final .. string.format("<font color = \"%s\">%s</font>", sepHighlight, sepGroup)
			
			sepGroup = ""
			wordGroup = ""
			return
		end
	end)
	
	if stringMode then
		final = final .. string.format("<font color = \"%s\">%s</font>", str_highlight, stringGroup)
	end
	
	return final .. wordGroup, stringMode
end

return highlighter
