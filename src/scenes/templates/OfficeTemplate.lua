--[[
OfficeTemplate.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Creates office scene modules from map, player, and camera declarations. Each scene instance receives independent runtime state through SceneContext.
The template coordinates input, movement, collision, animation playback, camera following, rendering, and UI updates.
Definitions and shared Color objects should be treated as read-only.
World coordinates use positive Y upward. Player Z defaults to the map's Z, which defaults to zero.
Reset restores the player's spawn position and facing; it does not rebuild the map or reset other entities.
SceneManager must attach a context before calling enter(). Game supplies InputManager and an optional menu callback through new().

[Dependencies]
src.core.Camera
src.classes.Color
src.entities.PlayerOffice
src.generation.OfficeMapBuilder
src.systems.OfficeControlSystem
src.systems.OfficeMovementSystem
src.systems.AnimationSystem
src.systems.CameraSystem
src.systems.RenderSystem

- [.define]                 Accepts a declaration and returns a scene module with new()

Generated scene methods:
- [.new]                    Creates an instance from input and optional onMenu callback

- [:enter]                  Builds the map, player, and camera

- [:update]                 Runs gameplay systems, camera following, and UI updates
- [:draw]                   Draws the world through the camera, then screen-space UI

- [:keyPressed]             Handles reset and menu actions
- [:mousepressed]           Forwards mouse presses to UI
- [:wheelmoved]             Forwards wheel input and pointer position to UI

- [:resize]                 Refreshes the camera for the current window dimensions
]]

local Camera = require("src.core.Camera")
local Color = require("src.classes.Color")
local PlayerOffice = require("src.entities.PlayerOffice")
local OfficeMapBuilder = require("src.generation.OfficeMapBuilder")

local OfficeControlSystem = require("src.systems.OfficeControlSystem")
local OfficeMovementSystem = require("src.systems.OfficeMovementSystem")
local AnimationSystem = require("src.systems.AnimationSystem")
local CameraSystem = require("src.systems.CameraSystem")
local RenderSystem = require("src.systems.RenderSystem")

local OfficeTemplate = {}

local function updateCamera(scene)
    local context = scene.context
    local map = scene.definition.map

    CameraSystem.update(context.world, scene.camera, context.entities.player, map.width, map.height)
end

local function resetPlayer(scene)
    local player = scene.context.world:get(scene.context.entities.player)

    player.position:setX(scene.spawn.x)
    player.position:setY(scene.spawn.y)
    player.position:setZ(scene.spawn.z)

    player.velocity:stop()
    player.officeMovement.facing = "down"

    scene.input.lastShiftPress = nil

    updateCamera(scene)
end

function OfficeTemplate.define(definition)
    assert(type(definition) == "table", "expected an office scene definition")
    assert(type(definition.map) == "table", "Expected a map definition")
    assert(type(definition.player) == "table", "Expected player settings")
    assert(definition.camera == nil or type(definition.camera) == "table", "Camera settings must be a table or nil")

    local Scene = {}
    Scene.__index = Scene

    function Scene.new(input, onMenu)
        assert(type(input) == "table", "Expected an InputManager instance")
        assert(onMenu == nil or type(onMenu) == "function", "Menu callback must be a function or nil")

        return setmetatable({
            definition = definition,
            input = input,
            onMenu = onMenu,
        }, Scene)
    end

    function Scene:enter()
        local context = self.context
        local world = context.world

        local map = self.definition.map
        local playerSettings = self.definition.player
        local cameraSettings = self.definition.camera or {}

        local z = playerSettings.z

        if z == nil then z = map.z or 0 end

        self.spawn = {
            x = playerSettings.x,
            y = playerSettings.y,
            z = z,
        }

        self.backgroundColor = self.definition.backgroundColor or Color.new255(25, 28, 35)

        self.camera = Camera.new(cameraSettings.zoom or 1)

        context.entities.map = OfficeMapBuilder.build(world, map)

        local playerId = PlayerOffice.create(
            world,
            self.spawn.x,
            self.spawn.y,
            self.spawn.z
        )

        context.entities.player = playerId

        local player = world:get(playerId)

        player.appearance.color = playerSettings.color or Color.new255(55, 120, 190)

        player.appearance.layer = playerSettings.layer or 20

        self.input.lastShiftPress = nil

        updateCamera(self)
    end

    function Scene:update(dt)
        local world = self.context.world

        OfficeControlSystem.update(world, self.input)
        OfficeMovementSystem.update(world, dt)
        AnimationSystem.update(world, dt)

        updateCamera(self)

        self.context.ui:update(dt)
    end

    function Scene:draw()
        love.graphics.clear(self.backgroundColor:unpack())

        self.camera:attach()
        RenderSystem.draw(self.context.world)
        self.camera:detach()

        self.context.ui:draw()
    end

    function Scene:keyPressed(key, scancode, isRepeat)
        local action = self.input:keyPressed(key, isRepeat)

        if action == "menu" then
            if self.onMenu then self.onMenu() end
            return
        end

        if action == "reset" then resetPlayer(self) end
    end

    function Scene:mousepressed(x, y, button)
        return self.context.ui:mousepressed(x, y, button)
    end

    function Scene:wheelmoved(dx, dy)
        local x, y = love.mouse.getPosition()

        return self.context.ui:wheelmoved(dx, dy, x, y)
    end

    function Scene:resize(width, height)
        updateCamera(self)
    end

    return Scene
end

return OfficeTemplate