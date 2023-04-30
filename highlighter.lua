local highlighter = {}

highlighter.lua_keywords = {"and", "break", "or", "else", "elseif", "if", "then", "end", "until", "repeat", "while", "do", "local", "in", "pairs", "ipairs", "return", "function"}
highlighter.rbx_keywords = {"game", "workspace", "script", "math", "string", "table", "wait", "select", "next", "Enum", "error", "warn", "tick", "assert", "_G", "shared", "loadstring", "tonumber", "tostring", "type", "typeof", "unpack", "print", "Instance", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor"}
highlighter.operators = {"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">", ",", ".", "(", ")", "{", "}", "[", "]", ";", ":"}

highlighter.colors = {
    numbers = {hex = "ffc600"},
    operator = {hex = "e8d228"},
    lua = {hex = "89ddff"},
    rbx = {hex = "92b4fd"},
    str = {hex = "38f157"},
    comment = {hex = "676e95", italics = true},
    boolean = {hex = "f78c6c"},
    null = {hex = "4f4f4f"},
    call = {hex = "82aaff"},
    self_call = {hex = "e3c98d"},
    local_color = {hex = "c792ea"},
    function_color = {hex = "89ddff", italics = true},
    local_property = {hex = "81deff"},
}

local function swapKeys(tab)
    for _, value in ipairs(tab) do
        tab[value] = true
    end
end

local function getHighlight(tokens, index)
    local token = tokens[index]

    if highlighter.colors[token .. "_color"] then
        return highlighter.colors[token .. "_color"]
    end

    if tonumber(token) then -- number
        return highlighter.colors.numbers
    elseif token == "nil" then
        return highlighter.colors.null
    elseif token:sub(1, 1) == "-" and token:sub(2, 2) == "-" then
        return highlighter.colors.comment
    elseif highlighter.operators[token] then
        return highlighter.colors.operator
    elseif highlighter.rbx_keywords[token] then
        return highlighter.colors.rbx
    elseif highlighter.lua_keywords[token] then
        return highlighter.colors.lua
    elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
        return highlighter.colors.str
    elseif token == "true" or token == "false" then
        return highlighter.colors.boolean
    end

    if tokens[index + 1] == "(" then
        if tokens[index - 1] == ":" then
            return highlighter.colors.self_call
        end

        return highlighter.colors.call
    end

    if tokens[index - 1] == "." then
        if tokens[index - 2] == "Enum" then
            return highlighter.colors.rbx
        end

        return highlighter.colors.local_property
    end
end

function highlighter:GetHighlight(code, carryString, carryComment)
    local tokens = {}
    local currentToken = ""
    local skipCounter = 0
    local commentPersist = false

    local inString = carryString
    local inComment = carryComment

    for i = 1, #code do
        if skipCounter > 0 then
            skipCounter = skipCounter - 1
        else
            local character = code:sub(i, i)

            if inComment then -- comment stuff
                if character == "\n" and not commentPersist then -- exit comment if nextline and not persistant
                    inComment = false
                elseif character == "]]" and commentPersist then -- exit comment if persistant comment close and persistant
                    inComment = false
                    commentPersist = false
                else -- add character to the comment token
                    currentToken = currentToken .. character
                end
            elseif inString then -- string stuff
                if character == "\\" then
                    currentToken = currentToken .. character .. code:sub(i + 1, i + 1)
                elseif character == inString then -- exit string
                    currentToken = currentToken .. character
                    inString = false
                else -- add character to the string token
                    currentToken = currentToken .. character
                end
            else -- comment > string > operators > everything else
                if character == "-" and code:sub(i + 1, i + 1) == "-" then
                    table.insert(tokens, currentToken)
                    currentToken = "--"
                    inComment = true
                    commentPersist = code:sub(i + 2, i + 2) == "[" and code:sub(i + 3, i + 3) == "["
                    skipCounter = 1
                elseif character == "\"" or character == "\'" then
                    table.insert(tokens, currentToken)
                    currentToken = character
                    inString = character
                elseif highlighter.operators[character] then
                    table.insert(tokens, currentToken)
                    table.insert(tokens, character)
                    currentToken = ""
                elseif character:match("%w") or character == "_" then
                    currentToken = currentToken .. character
                else
                    table.insert(tokens, currentToken)
                    table.insert(tokens, character)
                    currentToken = ""
                end
            end
        end
    end
    table.insert(tokens, currentToken)

    local highlighted = ""

    for i, token in pairs(tokens) do
        local highlight = getHighlight(tokens, i)

        if highlight then
            local syntax = string.format("<font color = \"#%s\">%s</font>", highlight.hex, token)

            if highlight.bold then
                syntax = string.format("<b>%s</b>", syntax)
            elseif highlight.italics then
                syntax = string.format("<i>%s</i>", syntax)
            end

            highlighted = highlighted .. syntax
        else
            highlighted = highlighted .. token
        end
    end

    return highlighted, inString, inComment
end

swapKeys(highlighter.lua_keywords)
swapKeys(highlighter.rbx_keywords)
swapKeys(highlighter.operators)

return highlighter
