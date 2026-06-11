local Temp_dui = nil
local Temp_dui_width = 2560
local Temp_dui_hight = 1440
local Temp_TexDict = ''
local Temp_Tx = ''

-- Ensure tracking table exists
CurrentDUI = CurrentDUI or {}

function CreateReplaceTextures(TexDict, TexToReplace, Url, Width, Hight)
    local RandomInt = math.random(0, 1000)
    local RandomStringForTxd = 'FRNT_DUIINT_RPTEX' .. RandomInt
    local RandomStringForTx = 'FRNT_DUIINT_RPTX' .. RandomInt
    local txd = CreateRuntimeTxd(RandomStringForTxd)
    Temp_TexDict = TexDict
    Temp_Tx = TexToReplace

    -- create DUI and store into consistent variables
    Temp_dui = CreateDui(Url, Width, Hight)
    Temp_dui_width = Width or Temp_dui_width
    Temp_dui_hight = Hight or Temp_dui_hight

    local duiHandle = GetDuiHandle(Temp_dui)

    CreateRuntimeTextureFromDuiHandle(
        txd,
        RandomStringForTx,
        duiHandle
    )

    AddReplaceTexture(
        TexDict,            -- Original TXD
        TexToReplace,       -- Original Texture
        RandomStringForTxd, -- New TXD
        RandomStringForTx   -- New Texture
    )

    Wait(1000)

    -- ensure duiHandle created before registering
    if not Temp_dui or not duiHandle then return false, 0 end

    CurrentDUI[Temp_dui] =
    {
        Type = 'ReplaceTexture',
        Width = Temp_dui_width,
        Height = Temp_dui_hight,
        DuiId = Temp_dui,
        OriginalTxd = Temp_TexDict,
        OriginalTx = Temp_Tx,
        ScriptedTxd = RandomStringForTxd,
        ScriptedTx = RandomStringForTx,
        Active = true
    }

    return true, Temp_dui
end

RegisterCommand('TestReplaceTexture', function()
    local Model = 'prop_busstop_05'
    local Texture = 'prop_busstop_poster_02'

    local url = ("https://cfx-nui-%s/nui/index.html"):format(GetCurrentResourceName())

    local Worked, Dui = CreateReplaceTextures(Model, Texture, url, 512, 1024)

    -- 785.2546, -1370.8431, 26.6427, 182.7581

    exports.ox_target:addSphereZone({
        coords = vec3(785.2546, -1370.8431, 26.6427),
        radius = 0.8,
        debug = false,
        drawSprite = false,
        options = {
            {
                name = 'interactwithdui',
                icon = 'fa-solid fa-circle',
                label = 'Interact With Screen',
                onSelect = function(data)
                    InteractWithDUI(Dui, false, vector3(785.3433, -1369.1003, 26.6035),
                    vector3(785.2546, -1370.8431, 26.6427), true, 'frontier_duiinteractions')
                end
            }
        }
    })

    if Worked then
        Wait(10000)
        DestoryDUI(Dui)
    end
end, false)

exports('CreateReplaceTextures',CreateReplaceTextures)