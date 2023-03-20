# **RichText Highlighter**
A useful module that can take in a string, parse and apply highlights then return the correctly highlighted string.

## *Usage*
Very simple and straightforward to use.

```lua
local highlighter = require(moduleScript) -- however you want to require the module doesn't matter what (require(), loadstring(game:GetHttp()), etc)

local stringToBeHighlighted = "local a = true; print(a)"
local highlightedString = highlighter:GetHighlight(stringToBeHighlighted) -- now you can apply this to a textbox that has the `RichText` property enabled!
```
