CurrentDUI = {}
IsClientFocused = false
CurrentClientCamera = nil
CurrentKeyboardDUI = nil
CurrentInteractDUI = nil

local DuiGameCallbacks = {}

function DestoryDUI(DUI)
    if DUI then
        if CurrentDUI[DUI].Type == 'ReplaceTexture' then
            RemoveReplaceTexture(CurrentDUI[DUI].OriginalTxd, CurrentDUI[DUI].OriginalTx)
        elseif CurrentDUI[DUI].Type == 'RenderedTarget' then
            CurrentDUI[DUI].Active = false
        end

        DestroyDui(DUI)
        CurrentDUI[DUI] = nil
    end
end

function InteractWithDUI(DuiTarget, IsEntity, CamCoords, Cooords, FocusKeyboard, ResourceName)
    if IsClientFocused then return end
    CurrentInteractDUI = DuiTarget
    if not IsDuiAvailable(DuiTarget) then
        print('^3 Error^0 Dui not available')
        return
    end

    IsClientFocused = true

    if FocusKeyboard then
        SetNuiFocus(true, false)

        print(ResourceName)

        if FocusKeyboard then
            CurrentDUI[DuiTarget].KeyboardResource = ResourceName
            CurrentKeyboardDUI = DuiTarget
        end
    end

    local CameraFocus = vector3(0, 0, 0)
    local camPos = vector4(0,0,0,0)

    if IsEntity then
        CameraFocus = CurrentDUI[DuiTarget].DuiEntity
        camPos = GetOffsetFromEntityInWorldCoords(
            CameraFocus,
            0.0,
            -0.4,
            0.4
        )
    else
        CameraFocus = Cooords
        camPos = CamCoords
    end

    FreezeEntityPosition(PlayerPedId(), true)

    CurrentClientCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(CurrentClientCamera, camPos.x, camPos.y, camPos.z)
    if IsEntity then
        PointCamAtEntity(CurrentClientCamera, CameraFocus, 0.0, 0.0, 0.4, true)
    else
        PointCamAtCoord(CurrentClientCamera, CameraFocus.x,CameraFocus.y,CameraFocus.z)
    end

    SetCamActive(CurrentClientCamera, true)
    RenderScriptCams(true, false, 0, true, true)

    CreateThread(function()
        while IsClientFocused do
            Wait(0)
            DisableAllControlActions(0)
            SetMouseCursorActiveThisFrame()

            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)

            local mx = GetDisabledControlNormal(0, 239)
            local my = GetDisabledControlNormal(0, 240)

            local px = math.floor(mx * CurrentDUI[DuiTarget].Width)
            local py = math.floor(my * CurrentDUI[DuiTarget].Height)

            if DuiTarget then
                SendDuiMouseMove(DuiTarget, px, py)

                if IsDisabledControlJustPressed(0, 24) then
                    SendDuiMouseDown(DuiTarget, "left")
                end

                if IsDisabledControlJustReleased(0, 24) then
                    SendDuiMouseUp(DuiTarget, "left")
                end

                if IsDisabledControlJustPressed(0, 25) then
                    SendDuiMouseDown(DuiTarget, "right")
                end

                if IsDisabledControlJustReleased(0, 25) then
                    SendDuiMouseUp(DuiTarget, "right")
                end

            end

            if IsDisabledControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 200) then
                UnfocusFromDUI()
            end
        end
    end)
end

function UnfocusFromDUI()
    if not IsClientFocused then return end

    IsClientFocused = false

    -- If a game callback is still pending, the player ESC'd mid-game → treat as fail
    if CurrentInteractDUI then
        local key = tostring(CurrentInteractDUI)
        if DuiGameCallbacks[key] then
            local cb = DuiGameCallbacks[key]
            DuiGameCallbacks[key] = nil
            CreateThread(function() cb(false) end)
        end
        CurrentInteractDUI = nil
    end

    if CurrentClientCamera then
        SetCamActive(CurrentClientCamera, false)
        DestroyCam(CurrentClientCamera, false)
        RenderScriptCams(false, false, 1, true, true)
        CurrentClientCamera = nil
    end

    FreezeEntityPosition(PlayerPedId(), false)
    SetNuiFocus(false, false)
end

RegisterNUICallback("duiKey", function(data, cb)
    if not IsClientFocused then return end

    -- SendDuiMessage(dui, json.encode({
    --     type = "key",
    --     key = data.key
    -- }))

    TriggerEvent(CurrentDUI[CurrentKeyboardDUI].KeyboardResource .. ':KeyClicked', CurrentKeyboardDUI, data.key)

    if data.key == 'Escape' then
        UnfocusFromDUI()
    end

    cb("ok")
end)

RegisterNetEvent('dui_interactions:KeyClicked', function(DUI, Key)
    SendDuiMessage(DUI, json.encode({
        type = "key",
        key = Key
    }))
end)

-- Exports
exports('DestoryDUI', DestoryDUI)
exports('InteractWithDUI', InteractWithDUI)
exports('UnfocusFromDUI', UnfocusFromDUI)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    print('Resource stopping')

    for k, v in pairs(CurrentDUI) do
        print(('Entry %s'):format(k))

        if v.Type == 'ReplaceTexture' then
            print(('TXD: %s TX: %s'):format(
                tostring(v.OriginalTxd),
                tostring(v.OriginalTx)
            ))

            pcall(function()
                RemoveReplaceTexture(
                    v.OriginalTxd,
                    v.OriginalTx
                )
            end)
        end

        if v.DuiId then
            pcall(function()
                DestroyDui(v.DuiId)
            end)
        end
    end
end)
