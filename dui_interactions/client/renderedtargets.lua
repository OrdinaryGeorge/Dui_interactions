local Temp_dui = nil
local Temp_dui_width = 2560
local Temp_dui_hight = 1440
local Temp_renderId = nil
local Temp_Model = ``


function CreateRenderedTarget(Entity, Model, Url, Width, Hight, AllModels) -- All models is a WIP
    if not DoesEntityExist(Entity) then
        return false, 0
    end

    if not Url or not string.find(Url, "%.html") then
        return false, 0
    end

    Temp_Model = Model
    Temp_dui_hight = Hight
    Temp_dui_width = Width

    if not IsNamedRendertargetRegistered("tvscreen") then
        RegisterNamedRendertarget("tvscreen", false)
    end

    LinkNamedRendertarget(Temp_Model)


    Temp_renderId = GetNamedRendertargetRenderId("tvscreen")

    print("^2[TV TEST]^7 RT ID:", Temp_renderId)

    Temp_dui = CreateDui(Url, Temp_dui_width, Temp_dui_hight)

    while not IsDuiAvailable(Temp_dui) do
        Wait(100)
    end

    local handle = GetDuiHandle(Temp_dui)

    if AllModels then
        local txd = CreateRuntimeTxd("tv_dui")
        CreateRuntimeTextureFromDuiHandle(
            txd,
            "tv_texture",
            handle
        )
    else
        local txd = CreateRuntimeTxd("tv_dui" .. Entity)
        CreateRuntimeTextureFromDuiHandle(
            txd,
            "tv_texture" .. Entity,
            handle
        )
    end

    CurrentDUI[Temp_dui] =
    {
        Type = 'RenderedTarget',
        CurRenderID = Temp_renderId,
        Width = Temp_dui_width,
        Height = Temp_dui_hight,
        DuiId = Temp_dui,
        DuiHandle = handle,
        DuiEntity = Entity,
        Active = true
    }

    local threadDui      = Temp_dui
    local threadRenderId = Temp_renderId

    CreateThread(function()
        local Txd = ''
        local Txs = ''

        if AllModels then
            Txd = 'tv_dui'
            Txs = 'tv_texture'
        else
            Txd = 'tv_dui' .. Entity
            Txs = 'tv_texture' .. Entity
        end

        while CurrentDUI[threadDui] and CurrentDUI[threadDui].Active do
            Wait(0)

            if threadRenderId then
                SetTextRenderId(threadRenderId)

                DrawSprite(
                    Txd,
                    Txs,
                    0.5,
                    0.5,
                    1.0,
                    1.0,
                    0.0,
                    255,
                    255,
                    255,
                    255
                )

                SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            else
                Wait(1)
            end
        end
    end)

    print('^4[Rendered_TargetDebug]^0 ' .. json.encode({
        CurRenderID = Temp_renderId,
        Width = Temp_dui_width,
        Height = Temp_dui_hight,
        DuiId = Temp_dui,
        DuiHandle = handle,
        DuiEntity = Entity,
        Active = true
    }))

    print('^4 Dui and Rendered Target Created! Info: ' .. Temp_dui)

    return true, Temp_dui
end

RegisterCommand('TestRenderedTargets', function()
    local Temp1_Model = `prop_monitor_w_large`
    PlyCords = GetEntityCoords(PlayerPedId())

    print('Got Shit')

    RequestModel(Temp1_Model)

    while not HasModelLoaded(Temp1_Model) do
        Wait(0)
    end

    print('Model successfully requested (' .. Temp1_Model .. ')')

    local Object = CreateObject(Temp1_Model, PlyCords.x + 1.0, PlyCords.y + 1.0, PlyCords.z, false, true, false)

    print('Spawned Model.... (' .. Object .. ')')

    Wait(10)
    FreezeEntityPosition(Object, true)

    local url = ("https://cfx-nui-%s/nui/index.html"):format(GetCurrentResourceName())

    local Works, DUI = CreateRenderedTarget(Object, Temp1_Model, url, 512, 256, false)

    exports.ox_target:addLocalEntity(Object, {
        {
            name = 'interact_with_screen',
            icon = 'fas fa-laptop-code',
            label = 'Use Screen',
            onSelect = function(data)
                InteractWithDUI(DUI, true, vector4(0, 0, 0, 0), vector3(0, 0, 0), true, 'dui_interactions')
            end
        },
    })
end, false)

exports('CreateRenderedTarget',CreateRenderedTarget)