# DUI Interactions

A lightweight FiveM resource for creating, rendering, and interacting with DUI surfaces on entities, world-space polygons, and texture replacements.

> ⚠️ **Work In Progress**
>
> Some exports and features are still under development and may change in future releases.

---

## Features

* Render DUIs directly onto supported props
* Replace existing game textures with live DUI content
* Create world-space DUI polygons
* Mouse and keyboard interaction support
* Runtime DUI creation and destruction
* Multiple active DUIs supported

---

# Dependencies

### Required

* FiveM server artifact with DUI support
* Ox_Lib
* Lua 5.4 enabled
* OneSync (recommended)

### Recommended Tools

The following tools are highly recommended when working with texture replacements and DUI placement:

* **OpenIV** – Browse game assets, texture dictionaries (`.ytd`), and model files
* Or
* **CodeWalker** – Inspect models, world objects, texture names, and placement data

### DUI Content Requirements

DUI content is rendered using Chromium Embedded Framework (CEF). For the best experience:

* Use websites or UIs compatible with modern Chromium browsers
* Optimise pages for the resolution you intend to render
* Minimise excessive animations and resource-heavy content
* Test interactions thoroughly if using custom JavaScript frameworks
* Avoid loading large numbers of DUIs simultaneously where possible

---

# Credits

### Creator

**DUI Interactions** was designed and developed by **Ordinary George**.

### Acknowledgements

Special thanks to:

* **ChatGPT** in help and research into the DUI topic and helping me scoure the FiveM Forums and Github to find support from others and others code to help me further understand DUI
* **Cody Raves** Where i refered to some code snippets to use for this resource where it helped me develop my understanding of this topic
* Everyone who contributes feedback, bug reports, feature suggestions, and testing during development.

### Community Support

This project exists because of the FiveM community and the people who continue pushing the boundaries of what can be achieved with in-game web technologies.

If you use this resource in your server or project, attribution is always appreciated.

---

# Contributing

Contributions are welcome.

If you would like to help improve the project, please:

1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with a clear description of your changes.

When reporting issues, please include:

* Resource version
* Server artifact version
* Creation method used (`RenderedTarget`, `ReplaceTextures`, or `PolyDui`)
* Relevant console errors
* Steps required to reproduce the issue

This helps identify and resolve problems much faster.

---

# License

Unless otherwise stated, this project is released under the **MIT License**.

You are free to:

* Use
* Modify
* Distribute for free
* Fork

Provided that the original license and copyright notice remain included with any substantial portions of the software.

---


# Creating DUIs

## Create a Rendered Target

Creates a DUI rendered directly onto a supported entity.

### Example

```lua
local Success, DUI = exports['dui_interactions']:CreateRenderedTarget(
    MonitorEntity, -- Entity to render onto
    MonitorModel,  -- Entity model
    Url,           -- URL to load
    Width,         -- Render width
    Height,        -- Render height
    true           -- Reserved / WIP
)
```

### Supported Models

The following models are currently known to work:

```lua
prop_monitor_w_large
prop_monitor_02

prop_tv_flat_01
prop_tv_flat_01_screen
prop_tv_flat_02
prop_tv_flat_02b
prop_tv_flat_03
prop_tv_flat_03b
prop_tv_flat_michael

prop_tv_02
prop_tv_03
prop_tv_03_overlay
prop_tv_06

prop_cs_tv_stand
prop_flatscreen_overlay
prop_trev_tv_01

hei_prop_hst_laptop
hei_bank_heist_laptop

des_tvsmash_start
des_tvsmash_root
des_tvsmash_end

prop_huge_display_01
prop_huge_display_02
```

### Returns

| Return    | Description                                 |
| --------- | ------------------------------------------- |
| `Success` | Whether the DUI was created successfully    |
| `DUI`     | DUI handle used for interaction and cleanup |

---

## Create a Texture Replacement

Creates a DUI and replaces an existing game texture. 

⚠️ **Please note any / all embbedded textures won't work.**

### Example

```lua
local Success, DUI = exports['dui_interactions']:CreateReplaceTextures(
    TexDict,       -- Texture dictionary
    TexToReplace,  -- Texture name
    Url,           -- URL to load
    Width,         -- Render width
    Height         -- Render height
)
```

### Returns

| Return    | Description                                 |
| --------- | ------------------------------------------- |
| `Success` | Whether the DUI was created successfully    |
| `DUI`     | DUI handle used for interaction and cleanup |

---

## Create a Poly DUI

Creates a world-space DUI surface between two points.

⚠️ **Please note this can be very resource heavy and I have tried to optimise it as much as possible.**

### Example

```lua
local Success, DUI = exports['dui_interactions']:CreatePolyDui(
    Poly1, -- First point
    Poly2, -- Second point
    Url,   -- URL to load
    Width, -- Render width
    Height -- Render height
)
```

### Poly Placement Helper

Launch the placement tool:

```lua
exports['dui_interactions']:StartPolyPlace()
```

The tool will print the selected coordinates to the console for easy reuse.

---

# Interacting With a DUI

Focuses a DUI and allows mouse/keyboard interaction.

### Example

```lua
exports['dui_interactions']:InteractWithDUI(
    DuiTarget, -- Dui
    IsEntity, -- Is it an entity you are targeting? only works forRendered target atm
    CamCoords, -- Manual Cam coords
    Cooords, -- Manual focus point (maybe the rntity coords if u want)
    FocusKeyboard, -- Do u want to use the keyboard on DUI if so follow the steps down below
    ResourceName -- the resource triggering this export
)
```

### Parameters

| Parameter       | Description                               |
| --------------- | ----------------------------------------- |
| `DuiTarget`     | DUI handle returned from creation exports |
| `IsEntity`      | Whether the DUI is attached to an entity  |
| `Coords`        | Focus position (`vector3`)                |
| `FocusKeyboard` | Enables keyboard input                    |
| `ResourceName`  | Resource requesting focus                 |

---

# Destroying a DUI

Destroys an existing DUI and frees associated resources.

### Example

```lua
exports['dui_interactions']:DestoryDUI(DUI)
```

---

# Keyboard Support

If your DUI contains text inputs or requires keyboard interaction, register the following event in your resource.

## Lua

```lua
RegisterNetEvent('MYRESOURCENAME:KeyClicked', function(DUI, Key)
    SendDuiMessage(DUI, json.encode({
        type = "key",
        key = Key
    }))
end)
```

---

## JavaScript (Inside Your DUI)

```javascript
window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data || data.type !== 'key') {
        return;
    }

    const key = data.key;

    const target =
        document.activeElement &&
        ['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)
            ? document.activeElement
            : document.body;

    const keyDownEvent = new KeyboardEvent('keydown', {
        key: key,
        bubbles: true,
        cancelable: true
    });

    target.dispatchEvent(keyDownEvent);

    if (target !== document.body) {
        if (key === 'Backspace') {
            target.value = target.value.slice(0, -1);
        } else if (key.length === 1) {
            target.value += key;
        }

        const inputEvent = new Event('input', {
            bubbles: true,
            cancelable: true
        });

        target.dispatchEvent(inputEvent);
    }
});
```

---

# Full Example

```lua
local Success, DUI = exports['dui_interactions']:CreateRenderedTarget(
    entity,
    model,
    "https://google.com",
    1920,
    1080,
    true
)

if Success then
    InteractWithDUI(
        DUI, -- Dui
        true, -- IsEntity? Rendered target uses an entity
        CamCoords, -- Unused if an entity but can disable IsEntity and use your own coords
        Cooords, -- Focus point for camera
        true, -- Focus keyboard
        ResourceName
    )
end
```

---

# Guide for Replace Texture

* Use OpenIV or Codewalker RPF Explorer and Open the entity...
* Then locate the ytd for the model this can be Model.ytd or Model+hifr.ytd
* You then can see the texture name.. and that is what you will use to replace it.
* Please be aware embbeded texures in the model from my knolege don't work.

* As an example opening the prop_busstop_05+hifr.ytd and I find the prop_busstop_poster_02 and replace that as seen in the example in the lua file.

---

# Notes

* Use **OpenIV** to locate texture dictionaries and texture names.
* Always store the returned DUI handle if you plan to interact with or destroy the DUI later.
* Keyboard functionality requires both the Lua event and JavaScript listener shown above.
* Texture replacement support is still being expanded.
* Poly DUIs are best suited for screens, billboards, signs, and custom world-space interfaces.

---

# Support

If you encounter issues, please include:

* Resource version
* Creation method used (`RenderedTarget`, `ReplaceTextures`, or `PolyDui`)
* Relevant console errors
* Reproduction steps

This makes diagnosing issues significantly easier.
