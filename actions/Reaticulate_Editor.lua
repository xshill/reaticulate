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


-- This file bootstraps either source or binary (precompiled) installations of
-- Reaticulate, depending on what's present.
--
-- More information, including source code, can be found at http://reaticulate.com/

-- Find base directory of application
local sep = package.config:sub(1, 1)
local script = debug.getinfo(1, 'S').source:sub(2)
local pattern = "(.*" .. sep .. ")[^" .. sep .. "]+" .. sep
local basedir = script:match(pattern)

if reaper.file_exists(basedir .. 'reaticulate.lua') then
    -- Monolith build used for distribution.
    dofile(basedir .. 'reaticulate.lua')
    main(basedir)
else
    -- Source code will be in this subdirectory.
    local appdir = basedir .. sep .. 'app' .. sep
    -- Replace package.path rather than appending to it as this improves module loading
    -- times (fewer paths to search) and we have no outside dependencies.  rtk is added as
    -- a submodule so is explicitly included in the path.
    package.path = string.format("%s?.lua;%s/rtk/?.lua;%s/rtk/?/init.lua", appdir, basedir, basedir)
    -- Also search up a level for rtk, in case it is not available as a submodule.  This is
    -- the case during rtk development.
    package.path = string.format('%s;%s/../rtk/?.lua;%s/../rtk/?/init.lua', package.path, basedir, basedir)
    -- Source based installation
    local editor = require 'maineditor'
    main(basedir)
end
