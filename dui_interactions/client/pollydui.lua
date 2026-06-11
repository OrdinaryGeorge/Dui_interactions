local Poly1
local Poly2
local IsCurrentlyCreating = false
local CurrentPolyDUI = {}

local RotationToDirection = function(rot)
    rot = rot or GetGameplayCamRot(2)
    local rotZ = rot.z * (3.141593 / 180.0)
    local rotX = rot.x * (3.141593 / 180.0)
    local c = math.cos(rotX)
    local multXY = math.abs(c)
    local res = vector3((math.sin(rotZ) * -1) * multXY, math.cos(rotZ) * multXY, math.sin(rotX))
    return res
end

local function DrawSelectedArea(PointA, PointB, minZ, maxZ, r, g, b, a)
    DrawPoly(PointB.x, PointB.y, minZ, PointB.x, PointB.y, maxZ, PointA.x, PointA.y, maxZ, r, g, b, a)
    DrawPoly(PointB.x, PointB.y, minZ, PointA.x, PointA.y, maxZ, PointA.x, PointA.y, minZ, r, g, b, a)
end

local function DrawImageOnArea(PointA, PointB, minZ, maxZ, r, g, b, a, texture, dict)
    DrawSpritePoly(PointB.x, PointB.y, minZ, PointB.x, PointB.y, maxZ, PointA.x, PointA.y, maxZ, r, g, b, a, texture,
        dict, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0)
    DrawSpritePoly(PointA.x, PointA.y, maxZ, PointA.x, PointA.y, minZ, PointB.x, PointB.y, minZ, r, g, b, a, texture,
        dict, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
end


local GetCoordsInFrontOfCam = function(...)
    local unpack            = table.unpack
    local coords, direction = GetGameplayCamCoord(), RotationToDirection()
    local inTable           = { ... }
    local retTable          = {}
    if (#inTable == 0) or (inTable[1] < 0.000001) then
        inTable[1] = 0.000001
    end
    for k, distance in pairs(inTable) do
        if (type(distance) == "number") then
            if (distance == 0) then
                retTable[k] = coords
            else
                retTable[k] = vector3(coords.x + (distance * direction.x), coords.y + (distance * direction.y),
                    coords.z + (distance * direction.z))
            end
        end
    end
    return unpack(retTable)
end

function StartPolyPlace()
    lib.showTextUI("[E] Select Start Point", {
        icon = 'fas fa-hand-pointer',
        position = 'left-center',
    })
    IsCurrentlyCreating = true

    while IsCurrentlyCreating do
        DisableControlAction(0, 38, true)
        local start, fin = GetCoordsInFrontOfCam(0, 5000)
        local ray = StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 4294967295, cache.ped, 5000)
        local _ray, hit, pos, norm, ent = GetShapeTestResult(ray)
        if hit then
            DrawSphere(pos, 0.06, 0, 255, 0, 0.5)
            if not Poly1 then
                if IsDisabledControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    Poly1 = pos
                    Poly2 = pos
                    Wait(100)
                    lib.showTextUI("[E] Select End Point ", {
                        icon = 'fas fa-hand-pointer',
                        position = 'left-center',
                    })
                end
            end
            if Poly2 then
                Poly2 = pos
                if IsDisabledControlJustReleased(0, 38) then
                    IsCurrentlyCreating = false
                end
            end
        end
        if Poly1 then
            DrawSelectedArea(Poly1, Poly2, Poly2.z, Poly1.z, 0, 155, 0, 80)
        end
        Wait(0)
    end
    lib.hideTextUI()
    if #(Poly1 - Poly2) < 50.0 then
        CurrentPolyDUI.pointA = Poly1
        CurrentPolyDUI.pointB = Poly2
        Poly1 = nil
        Poly2 = nil
        print('Poly Target Points \n Point 1: ' .. CurrentPolyDUI.pointA .. '\n Point 2: ' .. CurrentPolyDUI.pointB)
        return CurrentPolyDUI.pointA, CurrentPolyDUI.pointB
    else
        lib.notify({
            title = 'Poly Target',
            description = 'Target size is too large',
            type = 'error'
        })
    end
end

function CreatePolyDui(Poly1,Poly2,Url,Width,Hight)
    local Poly_Txd = 'PolyTexture_' .. tostring(math.random(1, 100000))
    local Poly_Txn = 'PolyTxn_' .. tostring(math.random(1, 100000))

    local Dui = CreateDui(Url, 1920, 1080)

    if not Url or not string.find(Url, "%.html") then
        return false, 0
    end

    Wait(500)
    local DuiHandle = GetDuiHandle(Dui)

    local Txd = CreateRuntimeTxd(Poly_Txd)
    local Texture = CreateRuntimeTextureFromDuiHandle(Txd, Poly_Txn, DuiHandle)

    local edgeX = Poly2.x - Poly1.x
    local edgeY = Poly2.y - Poly1.y

    if not DuiHandle then return false, 0 end

    CurrentDUI[Dui] = {
        Type = 'Poly',
        Width = 1920,
        Height = 1080,
        DuiId = Dui,
        DuiHandle = DuiHandle,
        Url = Url,
        Point1 = Poly1,
        Point2 = Poly2,
        Txd = Poly_Txd,
        Txn = Poly_Txn,
        Active = true
    }

    return true, Dui
end

RegisterCommand('CreatePolyDUIPoints', function()
    local Poly1, Poly2 = StartPolyPlace()

    local Url = ("https://cfx-nui-%s/nui/index.html"):format(GetCurrentResourceName())

    CreatePolyDui(Poly1,Poly2,Url,1920,1080)
end, false)

local MAX_POLYS = 4
local RENDER_DISTANCE = 35.0
local RENDER_DISTANCE_SQR = RENDER_DISTANCE * RENDER_DISTANCE

local PolysCurrentlyLoading = 0

CreateThread(function()
    while true do
        local rendered = 0
        local sleep = 1500

        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        local px = playerCoords.x
        local py = playerCoords.y
        local pz = playerCoords.z

        for id, v in pairs(CurrentDUI) do
            if rendered >= MAX_POLYS then
                break
            end

            if v.Type ~= 'Poly' then
                goto continue
            end

            if not v.Active or not v.Point1 or not v.Point2 then
                CurrentDUI[id] = nil
                goto continue
            end

            local center = v.Center

            if not center then
                center = vector3(
                    (v.Point1.x + v.Point2.x) * 0.5,
                    (v.Point1.y + v.Point2.y) * 0.5,
                    (v.Point1.z + v.Point2.z) * 0.5
                )

                v.Center = center
            end

            local p1 = v.Point1
            local p2 = v.Point2

            local dx1 = px - p1.x
            local dy1 = py - p1.y
            local dz1 = pz - p1.z

            local dist1Sqr = dx1 * dx1 + dy1 * dy1 + dz1 * dz1

            local dx2 = px - p2.x
            local dy2 = py - p2.y
            local dz2 = pz - p2.z

            local dist2Sqr = dx2 * dx2 + dy2 * dy2 + dz2 * dz2

            if dist1Sqr > RENDER_DISTANCE_SQR and dist2Sqr > RENDER_DISTANCE_SQR then
                goto continue
            end

            local cx = center.x
            local cy = center.y
            local cz = center.z

            local dx = px - cx
            local dy = py - cy
            local dz = pz - cz

            local distSqr = dx * dx + dy * dy + dz * dz

            sleep = 0

            local ray = StartShapeTestRay(
                px,
                py,
                pz,
                cx,
                cy,
                cz,
                4294967295,
                ped,
                0
            )

            local _, hit, hitPos = GetShapeTestResult(ray)

            if hit then
                local hdx = px - hitPos.x
                local hdy = py - hitPos.y
                local hdz = pz - hitPos.z

                if (hdx * hdx + hdy * hdy + hdz * hdz) + 0.01 < distSqr then
                    goto continue
                end
            end

            DrawImageOnArea(
                v.Point1,
                v.Point2,
                v.Point2.z,
                v.Point1.z,
                255,
                255,
                255,
                255,
                v.Txd,
                v.Txn
            )

            rendered = rendered + 1

            ::continue::
        end

        PolysCurrentlyLoading = rendered

        Wait(sleep)
    end
end)

exports('CreatePolyDui',CreatePolyDui)
exports('StartPolyPlace',StartPolyPlace)