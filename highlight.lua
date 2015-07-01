local M = {}

require "luacolor"

local words = {}

-- get attribute allocation number and register it in luacolor
local attribute = luatexbase.attributes.luahighlight
oberdiek.luacolor.setattribute(attribute)

-- make local version of luacolor.get

local get_color = oberdiek.luacolor.getvalue

-- we must save default color
local default_color 

function M.default_color(color)
  default_color = get_color(color)
end

function M.add_word(color,w)
  words[w] = color
end

local utfchar = unicode.utf8.char

-- we don't want to include punctation
local stop = {}
for _, x in ipairs {".",",","!","“","”","?"} do stop[x] = true end


function M.callback(head)
  local curr_text = {}
  local curr_nodes = {}
  for n in node.traverse(head) do
    if n.id == 37 then
      local char = utfchar(n.char)
      -- exclude punctation
      if not stop[char] then 
        curr_text[#curr_text+1] = char 
        curr_nodes[#curr_nodes+1] = n
      end
      -- set default color
      local current_color = node.has_attribute(n,attribute) or default_color
      node.set_attribute(n, attribute,current_color)
    elseif n.id == 10  then
      local word = table.concat(curr_text)
      curr_text = {}
      local color = words[word]
      if color then
        print(word)
        local colornumber = get_color(color)
        for _, x in ipairs(curr_nodes) do
          node.set_attribute(x,attribute,colornumber)
        end
      end
      curr_nodes = {}
    end
  end
  return head
end


return M
