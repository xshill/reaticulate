-- Copyright 2017-2022 Jason Tackaberry
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local BaseApp = require 'lib.baseapp'
local rtk = require 'rtk'
local rfx = require 'rfx'
local reabank = require 'reabank'
local articons = require 'articons'
local feedback = require 'feedback'
local json = require 'lib.json'
local log = rtk.log

require 'lib.utils'

App = rtk.class('App', BaseApp)

function App:initialize(basedir)
    if BaseApp.initialize(self, 'reaticulate_editor', 'Reaticulate Editor', basedir) == false then
        return
    end

    self.config = {}
    self.project_state = {
        msblsb_by_guid = {}
    }

    articons.init()
    rfx.init()
    reabank.init()

    if not self.config.art_colors then
        self.config.art_colors = {}
        for color, value in pairs(reabank.default_colors) do
            if reabank.colors[color] and reabank.colors[color] ~= value then
                self.config.art_colors[color] = value
            end
        end
    end

    self:add_screen('editor', 'editor.editor')
    self:replace_screen('editor')

    self:run()
end

function App:get_articulation_color(name)
    local color = self.config.art_colors[name] or reabank.colors[name] or reabank.default_colors[name]
    if color and color:len() > 0 then
        return color
    end
    -- This must be a custom color name.  Check for it in the reabank.
    color = reabank.colors[color]
    -- Return it if it's valid, otherwise fallback to the 'default' color.  We don't need
    -- to test color:len() as above because this isn't coming from settings where the
    -- empty string implies to use the built-in color.
    return color or self.config.art_colors.default or reabank.colors.default or reabank.default_colors.default
end

return App