-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function setup(opts)
    local handle = io.popen("git log --format='%an <%ae>'")
    local result = handle:read("*a")
    handle:close()


    local author_set = {}

    for author in result:gmatch("[^\r\n]+") do
        author_set[author] = true
    end

    local authors = {}

    for name,v in pairs(author_set) do
        table.insert(authors, name)
    end

    table.sort(authors)
    pickers.new(opts, {
        prompt_title = "Git Authors",
        finder = finders.new_table {
            results = authors,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_put({ selection[1] }, "", false, true)
            end)
            return true
        end
    }):find()
end

return setup
