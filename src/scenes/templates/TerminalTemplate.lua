--[[
TerminalTemplate.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Creates terminal scenes from explicit chunk placements. Each scene instance receives independent ECS and physics state.
Chunk placements use non-negative world offsets. World coordinates use positive Y upward.
Player selection identifies a chunk placement and its plot ID. Runs controls and physics at a fixed timestep, then synchronizes ECS.
Draws the world through a following camera and UI in screen coordinates. R resets only the player, not the map or other entities.
Escape invokes the supplied onMenu callback. Falling below the map resets the player.
SceneManager must attach SceneContext before enter(). Physics meter scale must be configured before creating the scene.

[Dependencies]
src.core.Camera
src.classes.Color
src.utils.NumberValidation
src.generation.TerminalChunkBuilder
src.generation.TerminalPropertiesFactories
src.systems.TerminalControlSystem
src.systems.TerminalPhysicsSystem
src.systems.AnimationSystem
src.systems.CameraSystem
src.systems.RenderSystem

- [.define]         Returns a scene module from a declaration

Generated methods:
- [.new]            Receives InputManager and optional onMenu callback
- [:enter]          Builds chunks, selects the player, and initializes the camera

- [:resetPlayer]    Restores the player's initial physics position

- [:update]         Runs physics, animation, camera, and UI
- [:draw]           Draws world and UI

- [:keyPressed]     Handles gameplay, reset, and leaving
- [:mousepressed]   Forwards mouse presses to UI
- [:wheelmoved]     Forwards wheel input to UI

- [:resize]         Refreshes camera boundaries

- [:exit]           Destroys the physics world

Definitions and property settings must be treated as read-only.
]]

local Camera = require("src.core.Camera")
local Color = require("src.classes.Color")
local Validation = require("src.utils.NumberValidation")

local Builder = require("src.generation.TerminalChunkBuilder")
local Factories = require("src.generation.TerminalPropertiesFactories")

local Controls = require("src.systems.TerminalControlSystem")
local Physics = require("src.systems.TerminalPhysicsSystem")
local Animation = require("src.systems.AnimationSystem")
local CameraSystem = require("src.systems.CameraSystem")
local Renderer = require("src.systems.RenderSystem")

local TerminalTemplate = {}

local FIXED_DT = 1 / 120
local MAX_FRAME_DT = 0.1

local function updateCamera(scene)
    CameraSystem.update(scene.context.world, scene.camera, scene.context.entities.player, scene.map.width, scene.map.height)
end

local function destroyPhysics(scene)
    if scene.context.physicsWorld then
        scene.context.physicsWorld:destroy()
        scene.context.physicsWorld = nil
    end
end

function TerminalTemplate.define(definition)
    assert(type(definition) == "table", "Expected a terminal definition")

    assert(type(definition.chunks) == "table" and #definition.chunks > 0, "Expected chunk placements")

    assert(type(definition.player) == "table", "Expected player selection")

    local tileSize = definition.tileSize or 32
    Validation.validateNumber(tileSize)
    assert(tileSize > 0, "Tile size must be positive")

    local playerChunk = definition.player.chunk

    Validation.validateNumber(playerChunk)
    assert(playerChunk % 1 == 0 and playerChunk >= 1 and playerChunk <= #definition.chunks, "Player chunk must identify a placement")

    assert(type(definition.player.plot) == "string", "Expected a player plot ID")

    for _, placement in ipairs(definition.chunks) do
        assert(type(placement.definition) == "table", "Placement requires a chunk definition")

        local x = placement.x or 0
        local y = placement.y or 0
        local z = placement.z or 0

        Validation.validateCoordinates(x, y, z)
        assert(x >= 0 and y >= 0, "Chunk offsets must be non negative")
    end

    local Scene = {}
    Scene.__index = Scene

    function Scene.new(input, onMenu)
        assert(type(input) == "table", "Expected InputManager")
        assert(onMenu == nil or type(onMenu) == "function", "onMenu must be a function or nil")

        return setmetatable({
            input = input,
            onMenu = onMenu,
        }, Scene)
    end

    function Scene:enter()
        local physicsSettings = definition.physics or {}
        local gravityX = physicsSettings.gravityX or 0
        local gravityY = physicsSettings.gravityY

        if gravityY == nil then gravityY = -1400 end

        Validation.validateNumber(gravityX)
        Validation.validateNumber(gravityY)

        self.context.physicsWorld = love.physics.newWorld(gravityX, gravityY, true)

        local ok, message = pcall(function()
            self.accumulator = 0

            self.map = {
                width = 0,
                height = 0,
                chunks = {},
            }

            for index, placement in ipairs(definition.chunks) do
                local built = Builder.build(
                    self.context,
                    placement.definition,
                    Factories,
                    {
                        tileSize = tileSize,
                        x = placement.x or 0,
                        y = placement.y or 0,
                        z = placement.z or 0,
                    }
                )

                self.map.chunks[index] = built

                self.map.width = math.max(self.map.width, built.x + built.width)

                self.map.height = math.max(self.map.height, built.y + built.height)
            end

            local selectedChunk = self.map.chunks[playerChunk]
            local playerId = selectedChunk.plots[definition.player.plot]

            assert(playerId, "Player plot was not built")

            local player = self.context.world:get(playerId)

            assert(
                player.physics
                    and player.position
                    and player.velocity
                    and player.collider
                    and player.platformMovement
                    and player.platformBody
                    and player.playerControlled,
                "Selected plot must create a physics driven terminal player"
            )

            for id, entity in self.context.world:query("playerControlled") do
                entity.playerControlled.enabled = id == playerId
            end

            self.context.entities.player = playerId
            self.context.entities.map = self.map

            self.spawnX, self.spawnY = player.physics.body:getPosition()

            self.spawnZ = player.position.z

            local cameraSettings = definition.camera or {}
            self.camera = Camera.new(cameraSettings.zoom or 2)

            self.backgroundColor = definition.backgroundColor or Color.new255(20, 24, 32)

            self.input.lastShiftPress = nil

            Physics.sync(self.context.world)
            updateCamera(self)
        end)

        if not ok then
            destroyPhysics(self)
            error(message, 0)
        end
    end

    function Scene:resetPlayer()
        local player = self.context.world:get( self.context.entities.player)

        local body = player.physics.body

        body:setPosition(self.spawnX, self.spawnY)
        body:setLinearVelocity(0, 0)
        body:setAwake(true)

        player.position:setZ(self.spawnZ)
        player.platformMovement.jumpRequested = false
        player.platformMovement.facing = "right"

        self.input.lastShiftPress = nil

        Physics.sync(self.context.world)

        player.platformBody.grounded = false

        updateCamera(self)
    end

    function Scene:update(dt)
        Validation.validateNumber(dt)
        assert(dt >= 0, "Elapsed time must be non negative")

        local elapsed = math.min(dt, MAX_FRAME_DT)
        self.accumulator = self.accumulator + elapsed

        while self.accumulator >= FIXED_DT do
            Controls.update(self.context.world, self.input, FIXED_DT)
            self.context.physicsWorld:update(FIXED_DT)
            Physics.sync(self.context.world)

            self.accumulator = self.accumulator - FIXED_DT
        end

        local player = self.context.world:get(self.context.entities.player)

        if player.position.y < -tileSize * 4 then self:resetPlayer() end

        Animation.update(self.context.world, elapsed)
        updateCamera(self)
        self.context.ui:update(dt)
    end

    function Scene:draw()
        love.graphics.clear(self.backgroundColor:unpack())

        self.camera:attach()
        Renderer.draw(self.context.world)
        self.camera:detach()

        self.context.ui:draw()
    end

    function Scene:keyPressed(key, scancode, isRepeat)
        if isRepeat then return end

        local action = self.input:keyPressed(key, isRepeat)

        if action == "menu" then
            if self.onMenu then self.onMenu() end
            return
        end

        if action == "reset" then self:resetPlayer() return end

        Controls.keyPressed(self.context.world, key, action)
    end

    function Scene:mousepressed(x, y, button)
        return self.context.ui:mousepressed(x, y, button)
    end

    function Scene:wheelmoved(dx, dy)
        local x, y = love.mouse.getPosition()
        return self.context.ui:wheelmoved(dx, dy, x, y)
    end

    function Scene:resize()
        updateCamera(self)
    end

    function Scene:exit()
        destroyPhysics(self)
    end

    return Scene
end

return TerminalTemplate