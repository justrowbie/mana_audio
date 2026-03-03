local soundData = {}

local function loadAudioBank(audioBank)
    if not audioBank then return end
    local timeout = 500
    while not RequestScriptAudioBank(audioBank, false) do
        if timeout == 0 then
            return false
        else
            timeout -= 1
        end
        Wait(0)
    end
    return true
end

local function releaseAudioBank(audioBank)
    if not audioBank then return end
    ReleaseNamedScriptAudioBank(audioBank)
end

---@class PlaySoundParams
---@field audioBank? string
---@field audioName string|string[]
---@field audioRef string

local function playSound(data)
    if type(data.audioName) == 'string' then
        data.audioName = {data.audioName}
    end

    --nt: add stop sound logic
    soundData[cache.serverId] = {
        audioName = data.audioName,
        audioRef = data.audioRef,
        soundId = {}
    }
    loadAudioBank(data.audioBank)
    for i = 1, #data.audioName do
        local audioName = soundData[cache.serverId].audioName[i]
        local audioRef = soundData[cache.serverId].audioRef
        local soundId = GetSoundId()
        soundData[cache.serverId].soundId[audioName] = soundId
        PlaySoundFrontend(soundId, audioName, audioRef, false)
        ReleaseSoundId(soundId)
    end
    releaseAudioBank(data.audioBank)
end

exports('PlaySound', playSound)

RegisterNetEvent('mana_audio:client:playSound', playSound)

---@class PlaySoundFromEntityParams: PlaySoundParams
---@field entity number

---@param data PlaySoundFromEntityParams
local function playSoundFromEntity(data)
    if not DoesEntityExist(data.entity) then return end
    if type(data.audioName) == 'string' then
        data.audioName = {data.audioName}
    end

    --nt: add stop sound logic
    soundData[cache.serverId] = {
        audioName = data.audioName,
        audioBank = data.audioBank,
        audioRef = data.audioRef,
        audioEntity = data.entity, 
        soundId = {}
    }
    loadAudioBank(data.audioBank)
    for i = 1, #data.audioName do
        local audioName = soundData[cache.serverId].audioName[i]
        local audioRef = soundData[cache.serverId].audioRef
        local audioEntity = soundData[cache.serverId].audioEntity
        local soundId = GetSoundId()
        soundData[cache.serverId].soundId[audioName] = soundId
        PlaySoundFromEntity(soundId, audioName, audioEntity, audioRef, false, false)
        ReleaseSoundId(soundId)
    end
    releaseAudioBank(data.audioBank)
end

exports('PlaySoundFromEntity', playSoundFromEntity)

RegisterNetEvent('mana_audio:client:playSoundFromEntity', function(data)
    if not NetworkDoesEntityExistWithNetworkId(data.netId) then return end
    playSoundFromEntity({
        audioBank = data.audioBank,
        audioName = data.audioName,
        audioRef = data.audioRef,
        entity = NetworkGetEntityFromNetworkId(data.netId),
    })
end)

---@class PlaySoundFromCoordsParams: PlaySoundParams
---@field coords vector3
---@field range number

---@param data PlaySoundFromCoordsParams
local function playSoundFromCoords(data)
    if type(data.audioName) == 'string' then
        data.audioName = {data.audioName}
    end
    
    --nt: add stop sound logic
    soundData[cache.serverId] = {
        audioName = data.audioName,
        audioBank = data.audioBank,
        audioRef = data.audioRef,
        coords = data.coords,
        range = data.range,
        soundId = {}
    }
    loadAudioBank(soundData[cache.serverId].audioBank)
    for i = 1, #soundData[cache.serverId].audioName do
        local audioName = soundData[cache.serverId].audioName[i]
        local audioRef = soundData[cache.serverId].audioRef
        local audioCoords = soundData[cache.serverId].coords
        local audioRange = soundData[cache.serverId].range
        local soundId = GetSoundId()
        soundData[cache.serverId].soundId[audioName] = soundId
        PlaySoundFromCoord(soundId, audioName, audioCoords.x, audioCoords.y, audioCoords.z, audioRef, false, audioRange, false)
        ReleaseSoundId(soundId)
    end
    releaseAudioBank(soundData[cache.serverId].audioBank)
end

exports('PlaySoundFromCoords', playSoundFromCoords)
RegisterNetEvent('mana_audio:client:playSoundFromCoords', playSoundFromCoords)

--nt: add stop sound logic
local function stopSoundName(data)
    if data then
        for k,v in pairs(soundData[cache.serverId].soundId) do
            if k == data.audioName then
                StopSound(v)
                soundData[cache.serverId].soundId[k] = soundData[cache.serverId].soundId[k] - 1
            else
                StopSound(0)
            end
        end
        ReleaseNamedScriptAudioBank('audiodirectory/'..data.audioBank)
    end
end

exports('StopSound', stopSoundName)
RegisterNetEvent('mana_audio:client:stopSoundName', stopSoundName)