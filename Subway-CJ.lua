script_name('Subway-CJ')
script_author('chapo')
require('lib.moonloader')
local memory = require('memory')
local Vec3 = require('vector3d')

local VOLUME_SETTINGS = {
    COIN = 0.2, -- collect coin sound volume
    MAIN_MUSIC = 0.2 -- main music volume
}

local inicfg = require 'inicfg'
local directIni = 'Subway-CJ by chapo.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        Coins = 0,
        Score = 0
    },
}, directIni))
inicfg.save(ini, directIni)

local Res = getWorkingDirectory()..'\\resource\\Subway-CJ by chapo'
local STATE = { NONE = 0, LOBBY = 1, PLAY = 2 }
local Game = {
    Font = renderCreateFont('Trebuchet MS', 15, 5),
    Audio = { RandomSounds = 0, Stream = {} }, 
    Models = {
        265, -- (Ped skin) Tenpenny 
        269, -- (Ped skin) Big Smoke
        334, -- (Weapon) Nightstick
        336, -- (Weapon) Bat 
        365, -- (Weapon) Spray can
        1247, -- Coin
        3564, -- Train 2 (closed door)
        3585, -- Train
        3755, -- Lobby building
        11464, -- railway
    },
    Animations = {
        'run_1armed',
        'run_armed',
        'run_civi',
        'run_csaw',
        'run_fat',
        'run_fatold',
        'run_gang1',
        'run_left',
        'run_old',
        'run_player',
        'run_right',
        'run_rocket',
        'run_stop',
        'run_stopr',
        'run_wuzi',
        'sprint_civi',
        'sprint_panic',
        'sprint_wuzi',
        'swat_run',
        'turn_180',
        'turn_l',
        'turn_r',
        'walk_armed',
        'walk_civi',
        'walk_csaw',
        'walk_doorpartial',
        'walk_drunk',
        'walk_fat',
        'walk_fatold',
        'walk_gang1',
        'walk_gang2',
        'walk_old',
        'walk_player',
        'walk_rocket',
        'walk_shuffle',
        'walk_start',
        'walk_start_armed',
        'walk_start_csaw',
        'walk_start_rocket',
        'walk_wuzi',
        'weapon_crouch',
        'woman_idlestance',
        'woman_run',
        'woman_runbusy',
        'woman_runfatold',
        'woman_runpanic',
        'woman_runsexy',
        'woman_walkbusy',
        'woman_walkfatold',
        'woman_walknorm',
        'woman_walkold',
        'woman_walkpro',
        'woman_walksexy',
        'woman_walkshop',
        'xpressscratch',
    }
}
local Player = { Coins = ini.main.Coins, Score = { Current = 0, Highest = ini.main.Score, Start = 0 }, State = STATE.NONE, SavedPos = Vec3(0, 0, 0) }
local Object = { Pool = {} }
local Map = {
    Pos = Vec3(0, 0, 800),
    Bot = nil,
    EnemyPoints = { -5, -1, 3 },
    EnemyObject = {
        { model = 3585 },
        { model = 3585 },
        { model = 3564 },
        { model = 3564 },
        { model = 1422, heading = 90}
    },
    Len = 1000,
    Environment = { -- {model = 1, heading = 0, scale = 1, x = 0, y = 0, z = -1},
        {
            {model = 3988,  heading = 90, scale = 1, x = 0, y = 25, z = -1},
            {model = 10846, heading = 90, scale = 1, x = 20, y = -22, z = -2},
            {model = 10980, heading = 45, scale = 1, x = 70, y = -22, z = -2},
            {model = 3988,  heading = 90, scale = 1, x = 100, y = 25, z = -1},
            {model = 10380, heading = 90, scale = 1, x = 170, y = 0, z = -1},
            {model = 4004,  heading = 0, scale = 1, x = 295, y = 19, z = -1},
            {model = 4048,  heading = 0, scale = 1, x = 150 + 20 + 60, y = -20, z = -1},
            {model = 3980,  heading = 0, scale = 1, x = 150 + 20 + 60 + 140, y = -60, z = -1},
            {model = 4002,  heading = 0, scale = 1, x = 150 + 20 + 60 + 140, y = 30, z = -1}
        },
        {
            {model = 4690, heading = 200, scale = 1, x = 277, y = 90, z = -15},
            {model = 8499, heading = 200, scale = 1, x = 198, y = -78, z = -15},
            {model = 4576, heading = 90, scale = 1, x = 25, y = -78, z = -15},
            {model = 3582, heading = 45, scale = 1, x = 0, y = -18, z = -1},
            {model = 10038, x = 0, y = 30, z = - 18, heading = 270},
            {model = 3634, x = 30, y = - 15, z = 0, heading = 180},
            {model = 8527, x = 70, y = - 25, z = 0, heading = 180},
            {model = 9273, x = 70, y = 13, z = 0, heading = 270},
            {model = 9577, x = 70 + 100, y = 22, z = - 2, heading = 10},
            {model = 9577, x = 70 + 100, y = 22, z = - 2, heading = 10},
            {model = 19493, x = 70 + 100, y = - 22, z = - 2, heading = 90},
            {model = 19495, x = 70 + 100 + 20, y = - 22, z = - 2, heading = 90},
            {model = 13681, x = 70 + 100 + 20 + 20, y = - 24, z = - 2, heading = 180},
            {model = 6294, x = 70 + 100 + 20 + 20 + 35, y = 24, z = - 2, heading = 180},
            {model = 6286, x = 70 + 100 + 20 + 20 + 30, y = - 24, z = - 2, heading = 180},
            {model = 5891, x = 70 + 100 + 20 + 20 + 30 + 80, y = 24, z = - 4, heading = 0},
            {model = 9319, x = 70 + 100 + 20 + 20 + 30 + 80 + 20, y = - 24, z = - 4, heading = 0},
            {model = 9737, x = 70 + 100 + 20 + 20 + 30 + 80 + 20 + 50, y = 24, z = - 24, heading = 0},
            {model = 3597, x = 70 + 100 + 20 + 20 + 30 + 80 + 20 + 30, y = - 24, z = - 4, heading = 180},
            {model = 5183, x = 70 + 100 + 20 + 20 + 30 + 80 + 20 + 30 + 100, y = 24, z = 0, heading = 180},
            {model = 10980, x = 70 + 100 + 20 + 20 + 30 + 80 + 20 + 30 + 100, y = - 34, z = - 4, heading = 270}
        },
        {
            {model = 9217, heading = 190, scale = 1, x = 50, y = -65, z = -45},
            {model = 9217, heading = 170, scale = 1, x = 130, y = -80, z = -45},
            {model = 9217, heading = 190, scale = 1, x = 300, y = -80, z = -45},
            {model = 9217, heading = 190, scale = 1, x = 350, y = -80, z = -45},
            {model = 9217, heading = 0, scale = 1, x = 50, y = 80 + 6, z = -45},
            {model = 9217, heading = 0, scale = 1, x = 130, y = 80 + 6, z = -45},
            {model = 9217, heading = 0, scale = 1, x = 300, y = 80 + 6, z = -45},
            {model = 9217, heading = 0, scale = 1, x = 370, y = 80 + 6, z = -45},    
            {model = 18271, heading = 0, scale = 3, x = 20, y = 20, z = 0},    
            {model = 18271, heading = 0, scale = 3, x = 70, y = 20, z = 0},    
            {model = 695, heading = 0, scale = 3, x = 370, y = 60, z = -10},
            {model = 695, heading = 0, scale = 3, x = 260, y = -20, z = -10},
            {model = 847, heading = 0, scale = 3, x = 370, y = 80, z = 38}, 
            {model = 838, heading = 0, scale = 3, x = 300, y = 80, z = 35}
        },
        {
            {model = 17538, heading = 270, scale = 1, x = 0, y = -40, z = -20},
            {model = 10775, heading = 270, scale = 1, x = 47, y = 35, z = -0},
            {model = 11012, heading = 270, scale = 1, x = 120, y = -45, z = 0},
            {model = 10840, heading = 0, scale = 1, x = 270, y = -40, z = 0},
            {model = 12931, heading = 45, scale = 1, x = 200, y = 100, z = -15},
            {model = 3707, heading = 90, scale = 1, x = 380, y = 30, z = 0},
            {model = 7622, heading = 90, scale = 1, x = 380, y = -30, z = 0}, 
        }
    }
}

setmetatable(Object, {
    __index = function(self, key)
        if key == 'Add' then
            return function(Tag, modelId, pos, scale, rotate, heading, nocollision)
                local Result, Handle = pcall(createObject, modelId, pos.x, pos.y, pos.z)
                assert(Result, 'Error creating object with tag "'..Tag..'": '..Handle)
                if Result then
                    if scale then setObjectScale(Handle, scale) end
                    if rotate then setObjectRotation(Handle, rotate.x or 0, rotate.y or 0, rotate.z or 0) end
                    if heading then setObjectHeading(Handle, heading) end
                    if nocollision then setObjectCollision(Handle, not nocollision) end
                    local NewObject = { Handle = Handle, Tag = Tag or '__none__', Pos = pos }
                    setmetatable(NewObject, {
                        __index = function(self, method)
                            if method == 'Delete' then
                                return function()
                                    for k, v in ipairs(Object.Pool) do
                                        if v.Handle == self.Handle then
                                            table.remove(Object.Pool, k)
                                        end
                                    end
                                    deleteObject(self.Handle)
                                end
                            elseif method == 'SetHeading' then
                                return function(angle)
                                    setObjectHeading(self.Handle, angle)
                                end
                            elseif method == 'SetRotation' then
                                return function(rotationVector)
                                    setObjectRotation(self.Handle, rotationVector.x, rotationVector.y, rotationVector.z)
                                end
                            elseif method == 'GetPos' then
                                return function()
                                    local result, x, y, z = getObjectCoordinates(self.Handle)
                                    return result and Vec3(x, y, z) or Vec3(0, 0, 0)
                                end
                            end
                        end
                    })
                    table.insert(Object.Pool, NewObject)
                    return Object.Pool[#Object.Pool]
                else
                    print('ERROR CREATING OBJECT:', Handle)
                end
            end
        elseif key == 'DestroyAll' then
            return function()
                -->> Delete objects
                for k, v in ipairs(getAllObjects()) do
                    for ind, data in ipairs(Object.Pool) do
                        if v == data.Handle then
                            table.remove(Object.Pool, ind)
                            deleteObject(v)
                            break
                        end
                    end
                end
                
                -->> Delete bot
                if doesCharExist(Map.Bot) then
                    deleteChar(Map.Bot)
                end
            end
        elseif key == 'GetByTag' then
            return function(tag)
                local result = {}
                for k, v in ipairs(Object.Pool) do
                    if v.Tag:find(tag) then
                        table.insert(result, v)
                    end
                end
                return result
            end
        elseif key == 'GetByFullTag' then
            return function(tag)
                local result = {}
                for k, v in ipairs(Object.Pool) do
                    if v.Tag == tag then
                        return v
                    end
                end
                return nil
            end
        end
    end
})
setmetatable(Map, {
    __index = function(self, key)
        if key == 'GenerateMap' then
            return function(notFirst)
                Map.BuildEnvironment()
                -->> Create bot
                local BotSkin = {265, 269}
                local BotWeapon = {3, 5}
                local BotIndex = math.random(1, 2)
                Map.Bot = createChar(4, BotSkin[BotIndex], Map.Pos.x - 1.9, Map.Pos.y, Map.Pos.z)
                giveWeaponToChar(Map.Bot, BotWeapon[BotIndex], 1)
                setCurrentCharWeapon(Map.Bot, BotWeapon[BotIndex])
                setCharHeading(Map.Bot, 270)
                setCharCollision(Map.Bot, false)

                -->> Create lobby objects
                ---->> Trains
                Object.Add('Lobby_Train_1', 3564, Vec3(Map.Pos.x - 13.2, Map.Pos.y + 2.7, Map.Pos.z))
                Object.Add('Lobby_Train_2', 3564, Vec3(Map.Pos.x - 4.9, Map.Pos.y + 2.7, Map.Pos.z))
                Object.Add('Lobby_Train_3', 3585, Vec3(Map.Pos.x + 3.3, Map.Pos.y + 2.7, Map.Pos.z))
                Object.Add('Lobby_Train_4', 3564, Vec3(Map.Pos.x + 11.7, Map.Pos.y + 2.7, Map.Pos.z))

                ---->> Graffiti
                Object.Add('Lobby_Graffiti1', 18659, Vec3(Map.Pos.x + 0.4, Map.Pos.y + 1.4, Map.Pos.z + 0.7), nil, nil, 90)
                Object.Add('Lobby_Graffiti2', 18667, Vec3(Map.Pos.x + 0.4, Map.Pos.y + 1.4, Map.Pos.z + 0.7), nil, nil, 90)

                ---->> Buildings
                Object.Add('Lobby_Building_Left', 3755, Vec3(Map.Pos.x + 3.3, Map.Pos.y + 8, Map.Pos.z - 2.5), nil, nil, 0)
                Object.Add('Lobby_Building_Right', 3707, Vec3(Map.Pos.x + 10, Map.Pos.y - 37, Map.Pos.z + 0.7), 1, nil, 270)
                Object.Add('Lobby_Building_Wall_Left', 19456, Vec3(Map.Pos.x + 43.2, Map.Pos.y + 9.8, Map.Pos.z - 0.5), nil, nil, 0)
                Object.Add('Lobby_Building_Wall_Right', 19456, Vec3(Map.Pos.x + 43.2, Map.Pos.y - 11.8, Map.Pos.z - 0.5), nil, nil, 0)

                ---->> Background containers
                
                Object.Add('Lobby_Containers_Back', 8341, Vec3(Map.Pos.x - 35, Map.Pos.y - 25, Map.Pos.z + 0.7), nil, nil, 0)
                Object.Add('Lobby_Containers_Back', 17049, Vec3(Map.Pos.x - 30, Map.Pos.y + 9, Map.Pos.z + 0.3), nil, nil, -20)
                Object.Add('Lobby_Containers_Back', 10775, Vec3(Map.Pos.x - 85, Map.Pos.y - 40, Map.Pos.z ), nil, nil, 90)

                
                ---->> Floor
                Object.Add('Lobby_FloorLeft', 5309, Vec3(Map.Pos.x + 7, Map.Pos.y + 15, Map.Pos.z - 9), 1, nil, 0)
                Object.Add('Lobby_FloorRight', 5309, Vec3(Map.Pos.x + 7, Map.Pos.y - 17, Map.Pos.z - 9), 1, nil, 180)

                -->> Tunnels
                Object.Add('StartMapTunnel', 16024, Vec3(Map.Pos.x - 90, Map.Pos.y - 27, Map.Pos.z - 0), 1, Vec3(0, 0, -15), nil)
                Object.Add('EndMapTunnel', 16024, Vec3(Map.Pos.x + Map.Len + 70, Map.Pos.y - 15.5, Map.Pos.z - 2), 1, Vec3(0, 0, -60), nil)
                
                -->> Create  roads
                for index = 0, math.floor(Map.Len / 148) - 2 do
                    Object.Add('RailwayLeft'..index, 11464, Vec3(Map.Pos.x + 75 + (70 * index) + (148 * index), Map.Pos.y + 1, Map.Pos.z + 0.10), nil, Vec3(0, 0, 144), nil)
                    Object.Add('RailwayRight'..index, 11464, Vec3(Map.Pos.x + 75 + (70 * index) + (148 * index), Map.Pos.y - 7, Map.Pos.z + 0.13), nil, Vec3(0, 0, 144), nil)    
                end

                -->> Create walls
                for index = 5, Map.Len / 9.6 do
                    Object.Add('WallLeft'..index, 19456, Vec3(Map.Pos.x + 9.6 * index, Map.Pos.y + 5, Map.Pos.z - 0.5), nil, nil, 90)
                    Object.Add('WallRight'..index, 19456, Vec3(Map.Pos.x + 9.6 * index, Map.Pos.y - 7, Map.Pos.z - 0.5), nil, nil, 90)
                end
                -->> Building Wall
                Object.Add('BuildingWallRight', 19913, Vec3(Map.Pos.x + 20, Map.Pos.y - 7, Map.Pos.z), 0, nil, 0)
                Object.Add('BuildingWallLeft', 19913, Vec3(Map.Pos.x + 20, Map.Pos.y + 4.9, Map.Pos.z), 0, nil, 0)

                -->> Create "enemy"
                lua_thread.create(function()
                    local ObjectIndex = 0
                    for X = notFirst and 100 or 50, Map.Len, 15 do
                        ObjectIndex = ObjectIndex + 1
                        math.randomseed(os.clock() * math.random(110, 201931))
                        local Y_Index = math.random(1, 3)
                        wait(1 + math.random(1, 5)); math.randomseed(os.clock() * math.random(110, 201931))
                        local Data = Map.EnemyObject[math.random(1, #Map.EnemyObject)]
                        Object.Add('Enemy', Data.model, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[Y_Index] + (Data.y or 0), Map.Pos.z + 0 + (Data.z or 0)), Data.scale or 1, Data.rotate, Data.heading)
                        wait(1 + math.random(1, 5)); math.randomseed(os.clock() * math.random(110, 201931))
                        local BonusPos = Y_Index == 1 and math.random(2, 3) or (Y_Index == 3 and math.random(1, 2))
                        if BonusPos then
                            wait(1 + math.random(1, 5)); math.randomseed(os.clock() * math.random(110, 201931))
                            if math.random(1, 100) <= 30 then
                                -->> Sound
                                Object.Add('Bonus_Model_'..ObjectIndex, 19424, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[BonusPos] + (Data.y or 0), Map.Pos.z + 1 + (Data.z or 0)), 3, Vec3(90, 0, 90), nil, true)
                                Object.Add('Bonus_'..ObjectIndex, 19437, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[BonusPos] + (Data.y or 0), Map.Pos.z - 2.5 + (Data.z or 0)), 0, nil, 0, false)
                                Object.Add('Bonus_Model_'..ObjectIndex, 1276, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[BonusPos] + (Data.y or 0), Map.Pos.z + 0.7 + (Data.z or 0)), 0, Vec3(90, 0, 90), nil, true)
                            else
                                -->> Coin
                                Object.Add('Bonus_Model_'..ObjectIndex, 1247, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[BonusPos] + (Data.y or 0), Map.Pos.z + 1 + (Data.z or 0)), 2, nil, 90, true)
                                Object.Add('Bonus_'..ObjectIndex, 19437, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[BonusPos] + (Data.y or 0), Map.Pos.z - 2.5 + (Data.z or 0)), 0, nil, 0, false)
                                Object.Add('Bonus_Model_'..ObjectIndex, 1276, Vec3(Map.Pos.x + X + (Data.x or 0), Map.Pos.x + Map.EnemyPoints[BonusPos] + (Data.y or 0), Map.Pos.z + 0.7 + (Data.z or 0)), 0, Vec3(90, 0, 90), nil, true)    
                            end
                        end
                    end
                end)
            end
        elseif key == 'BuildEnvironment' then
            return function() 
                lua_thread.create(function()
                    wait(10)
                    math.randomseed(os.clock() * math.random(110, 201931))
                    local EnvironmentId = math.random(1, #Map.Environment)
                    print('EnvironmentId', EnvironmentId)
                    for X = Map.Pos.x + 85, Map.Len, 500 do
                        for k, v in ipairs(Map.Environment[EnvironmentId]) do
                            Object.Add('Environment', v.model, Vec3(Map.Pos.x + X + v.x, Map.Pos.y + v.y, Map.Pos.z + v.z), v.scale, nil, v.heading)
                        end
                    end
                end)
            end
        elseif key == 'GoToLobby' then
            return function()
                Object.DestroyAll()
                Map.GenerateMap()

                -->> Set PLAYER_PED params
                setCharCoordinates(PLAYER_PED, Map.Pos.x + 0.5, Map.Pos.y - 0.2, Map.Pos.z + 0.5)
                giveWeaponToChar(PLAYER_PED, 41, 1)
                setCurrentCharWeapon(PLAYER_PED, 41)
                setCharHeading(PLAYER_PED, 0)
                taskPlayAnim(PLAYER_PED, 'SPRAYCAN_FIRE', 'GRAFFITI', 100, true, true, true, true, -1)
            end
        end
    end
})
setmetatable(Game, {
    __index = function(self, key)
        if key == 'Toggle' then
            return function()
                if Player.State == STATE.NONE then
                    Player.State = STATE.LOBBY
                    Player.SavedPos = Vec3(getCharCoordinates(PLAYER_PED))
                    Map.GoToLobby()
                else
                    removeWeaponFromChar(PLAYER_PED, 41)
                    setCharCoordinates(PLAYER_PED, Player.SavedPos.x, Player.SavedPos.y, Player.SavedPos.z)
                    Player.State = STATE.NONE
                end
            end
        elseif key == 'LoadResources' then
            return function()
                -->> Load models
                requestAnimation('GRAFFITI')
                for index, id in ipairs(Game.Models) do
                    if not hasModelLoaded(id) then
                        requestModel(id)
                        loadAllModelsNow()
                    end
                end

                -->> Load Audio
                local function getFilesInPath(path, ftype)
                    local Files, SearchHandle, File = {}, findFirstFile(path.."\\"..ftype)
                    table.insert(Files, File)
                    while File do File = findNextFile(SearchHandle) table.insert(Files, File) end
                    return Files
                end

                local List = getFilesInPath(Res, '*.mp3')
                for k, v in ipairs(List) do
                    if v:match('(.+)%.mp3') then
                        local file = v:match('(.+)%.mp3')
                        if file:find('SOUND_RAND_(%d+)') then
                            Game.Audio.RandomSounds = Game.Audio.RandomSounds + 1
                        end
                        Game.Audio.Stream[file] = loadAudioStream(Res..'\\'..v)
                    end
                end
                assert(Game.Audio.Stream.SOUND_COIN, 'Error, SOUND_COIN not found')
                assert(Game.Audio.Stream.MAIN_PLAY, 'Error, MAIN_PLAY not found')
                assert(Game.Audio.Stream.SOUND_LOBBY_PLAY_CLICK, 'Error, SOUND_LOBBY_PLAY_CLICK not found')
            end
        elseif key == 'DisableAllRandomSounds' then
            return function()
                for k, v in pairs(Game.Audio.Stream) do
                    if k:find('SOUND_RAND_(%d+)') then
                        setAudioStreamState(Game.Audio.Stream[k], 0)
                    end
                end
            end
        end
    end
})

RakNetHandler = function() return Player.State == STATE.NONE end
addEventHandler('onSendRpc', function() return RakNetHandler() end)
addEventHandler('onReceiveRpc', function() return RakNetHandler() end)
addEventHandler('onSendPacket', function() return RakNetHandler() end)
addEventHandler('onReceivePacket', function() return RakNetHandler() end)
addEventHandler('onWindowMessage', function(msg, key)
    if msg == 0x0100 then
        if key == VK_SPACE and Player.State == STATE.LOBBY and isSampAvailable() and not sampIsCursorActive() then
            Player.Score.Start = os.clock()
            clearCharTasks(PLAYER_PED)
            setCharHeading(PLAYER_PED, 270)
            Player.State = STATE.PLAY
            setAudioStreamState(Game.Audio.Stream.SOUND_LOBBY_PLAY_CLICK, 1)
            setAudioStreamState(Game.Audio.Stream.MAIN_PLAY, 1)
            setAudioStreamLooped(Game.Audio.Stream.MAIN_PLAY, true)
            setAudioStreamVolume(Game.Audio.Stream.MAIN_PLAY, 0.1)
            consumeWindowMessage(true, true)
        end
    end
end)
addEventHandler('onScriptTerminate', function(scr, q)
    if scr == thisScript() then
        Object.DestroyAll()
        if Player.State ~= STATE.NONE then
            setCharCoordinates(PLAYER_PED, Player.SavedPos.x, Player.SavedPos.y, Player.SavedPos.z)
            removeWeaponFromChar(PLAYER_PED, 41)
        end
    end
end)

function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
        local entityPtr = getCharPointer(char)
        if entityPtr ~= 0 then
            local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
            if matrixPtr ~= 0 then
                local posPtr = matrixPtr + 0x30
                writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
                writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
                writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
            end
        end
    end
end

function main()
    assert(doesDirectoryExist(Res), 'Error, resource folder was not found!')
    while not isSampAvailable() do wait(0) end
    Game.LoadResources()
    sampRegisterChatCommand('subwaycj', function(arg)
        Game.Toggle()
        Game.DisableAllRandomSounds()
        setAudioStreamState(Game.Audio.Stream.MAIN_PLAY, 0)
    end)
    while true do
        wait(0)    
        if Player.State ~= STATE.NONE then
            local Pos = Vec3(getCharCoordinates(PLAYER_PED))
            if Player.State == STATE.LOBBY then
                setCameraPositionUnfixed(0, 4)
                printStyledString('~n~~n~~n~~n~~w~PRESS ~y~SPACE~w~ TO START', 30, 7)
            elseif Player.State == STATE.PLAY then
                 -->> Bot behaviour
                setCharCoordinatesDontResetAnim(Map.Bot, Pos.x - 4, Pos.y, Pos.z)
                setCharHeading(Map.Bot, getCharHeading(PLAYER_PED))
                taskPlayAnim(Map.Bot, 'RUN_PLAYER', 'PED', 100, true, true, true, true, -1)

                -->> Set PLAYER_PED settings
                memory.setint8(0xB7CEE4, 1) -- inf stamina
                setCameraPositionUnfixed(-0.2, 3.15)
                setGameKeyState(1, -256)
                setGameKeyState(16, 128)
                for _, AnimationName in ipairs(Game.Animations) do
                    setCharAnimSpeed(PLAYER_PED, AnimationName, 1 + Player.Score.Current / 50)
                end
                --printStringNow(('~y~$~w~%s~n~~y~Score:~w~ %s/~y~%s'):format(Player.Coins or 0, Player.Score.Current, Player.Score.Highest), 50)
                local resX, resY = getScreenResolution()
                renderFontDrawText(Game.Font, ('{ffdd61}${ffffff}%s'):format(Player.Coins or 0), resX / 2 - renderGetFontDrawTextLength(Game.Font, ('$%s'):format(Player.Coins or 0)) / 2, 50, 0xFFffffff)
                renderFontDrawText(Game.Font, ('%s/{4d4d4d}%s'):format(Player.Score.Current or 0, Player.Score.Highest or 0), resX / 2 - renderGetFontDrawTextLength(Game.Font, ('%s/%s'):format(Player.Score.Current or 0, Player.Score.Highest or 0)) / 2, 50 + 20, 0xFFffffff) 
                Player.Score.Current = math.floor(os.clock() - Player.Score.Start)
                if Player.Score.Current > Player.Score.Highest then Player.Score.Highest = Player.Score.Current end
                if Pos.x >= Map.Len then 
                    setCharCoordinatesDontResetAnim(PLAYER_PED, Map.Pos.x + 60, Pos.y, Map.Pos.z + 0.5)
                    Object.DestroyAll()
                    Map.GenerateMap(true)
                end

                -->> Die from enemy
                local List = Object.GetByTag('Enemy')
                for k, v in ipairs(List) do
                    if isCharTouchingObject(PLAYER_PED, v.Handle) then
                        Game.DisableAllRandomSounds()
                        setAudioStreamState(Game.Audio.Stream.MAIN_PLAY, 0)
                        setAudioStreamVolume(Game.Audio.Stream.MAIN_PLAY, VOLUME_SETTINGS.MAIN_MUSIC)
                        ini.main.Coins = Player.Coins
                        ini.main.Score = Player.Score.Highest
                        inicfg.save(ini, directIni)
                        Player.State = STATE.LOBBY
                        Map.GoToLobby()
                    else
                        if v.Pos.x < Pos.x and getDistanceBetweenCoords3d(Pos.x, Pos.y, Pos.z, v.Pos.x, v.Pos.y, v.Pos.z) > 10 then
                            v.Delete()
                        end
                    end
                end

                -->> Collect coins
                local Coins = Object.GetByTag('Bonus')
                for k, v in ipairs(Coins) do
                    if isCharTouchingObject(PLAYER_PED, v.Handle) then
                        local ID = v.Tag:match('Bonus_(%d+)')
                        if ID then
                            local Model = Object.GetByFullTag('Bonus_Model_'..ID)
                            if Model then 
                                local ObjectModelId = getObjectModel(Model.Handle)
                                if ObjectModelId == 1247 then
                                    printStyledString('~y~+ COIN', 500, 7)
                                    Player.Coins = Player.Coins + 1
                                    setAudioStreamState(Game.Audio.Stream.SOUND_COIN, 1)
                                    setAudioStreamVolume(Game.Audio.Stream.SOUND_COIN, VOLUME_SETTINGS.COIN)
                                elseif ObjectModelId == 19424 then
                                    printStyledString('~b~+ SOUND', 500, 7)
                                    Game.DisableAllRandomSounds()
                                    math.randomseed(os.clock() * math.random(1000, 99999))
                                    local randomSoundIndex = math.random(1, Game.Audio.RandomSounds)
                                    if Game.Audio.Stream['SOUND_RAND_'..randomSoundIndex] ~= nil then
                                        setAudioStreamState(Game.Audio.Stream['SOUND_RAND_'..randomSoundIndex], 1)
                                        setAudioStreamVolume(Game.Audio.Stream['SOUND_RAND_'..randomSoundIndex], 0.2)
                                    end
                                else
                                    printStyledString(ObjectModelId, 500, 7)
                                end
                                Model.Delete() 
                            end
                        end
                        v.Delete()
                    end
                end
            end
        end
    end
end