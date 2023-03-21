local highlighter = {}

highlighter.lua_globals = {"local", "while", "for", "do", "break", "return", "not", "if", "elseif", "else", "then", "end", "repeat", "until", "function", "and", "or"}
highlighter.rbx_globals = {"workspace", "game", "script", "math", "string", "table", "wait", "Color3", "BrickColor", "next", "select", "Instance", "Vector2", "Vector3", "UDim2", "Udim", "Enum", "error", "warn", "tick", "loadstring", "_G", "shared", "tonumber", "tostring", "type", "typeof", "in", "pairs", "ipairs", "print", "unpack"}
highlighter.operators = {"=", "-", "+", "*", "/", "^", "%", ";", "~", "(", ")", "[", "]", "{", "}", ",", ".", ":", "<", ">"}
highlighter.booleans = {"true", "false"}

highlighter.number_highlight = "#ffc600"
highlighter.operator_highlight = "#e8d228"
highlighter.lua_highlight = "#f15d5f"
highlighter.rbx_highlight = "#92b4fd"
highlighter.str_highlight = "#38f157"
highlighter.boolean_highlight = "#d68017"
highlighter.nil_highlight = "#4f4f4f"
highlighter.comment_highlight = "#666666"

local function GetHighlight(str)
	if tonumber(str) then
		return highlighter.number_highlight
	elseif str == "nil" then
		return highlighter.nil_highlight
	elseif table.find(highlighter.operators, str) then
		return highlighter.operator_highlight
	elseif table.find(highlighter.lua_globals, str) then
		return highlighter.lua_highlight
	elseif table.find(highlighter.rbx_globals, str) then
		return highlighter.rbx_highlight
	elseif table.find(highlighter.booleans, str) then
		return highlighter.boolean_highlight
	end

	return false
end

function highlighter:GetHighlight(text, inString)
	local final = ""
	local stringMode = inString or false
	local commentMode = false
	local stringGroup = ""
	local sepGroup = ""
	local wordGroup = ""
	
	local i = 0
	
	text:gsub(".", function(c)
		i = i + 1
		
		wordGroup = wordGroup .. c
		
		if commentMode then return end
		
		if text:sub(i + 1 , i + 2) == "--" then
			commentMode = true
		end
		
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
				final = final .. string.format("<font color = \"%s\">%s</font>", highlighter.str_highlight, stringGroup)
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
		final = final .. string.format("<font color = \"%s\">%s</font>", highlighter.str_highlight, stringGroup)
		
		wordGroup = ""
	end
	
	if commentMode then
		final = final .. string.format("<font color = \"%s\">%s</font>", highlighter.comment_highlight, wordGroup)
		
		wordGroup = ""
	end

	return final .. wordGroup, stringMode
end

return highlighter
