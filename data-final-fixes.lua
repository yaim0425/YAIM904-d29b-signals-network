---------------------------------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.reference_values()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)
            This_MOD.create_tech(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Valores a usar en control.lua
    This_MOD.load_styles()
    This_MOD.load_icon()
    This_MOD.load_sound()

    --- Fijar las posiciones actual
    GMOD.d00b.change_orders()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre de las entidades
    This_MOD.name_sender = This_MOD.prefix .. "sender"

    --- Nombre de la tecnología
    This_MOD.name_tech = This_MOD.prefix .. "transmission-tech"

    --- Ruta a los multimedias
    This_MOD.path_graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"
    This_MOD.path_sound = "__" .. This_MOD.prefix .. This_MOD.name .. "__/sound/"

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if GMOD.entities[This_MOD.name_sender] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores para el proceso
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Space = {}
    Space.combinator = GMOD.entities["decider-combinator"]
    Space.item = GMOD.get_item_create(Space.combinator, "place_result")
    Space.entity = GMOD.entities["radar"]

    Space.recipe = GMOD.recipes[Space.item.name]
    Space.tech = GMOD.get_technology(Space.recipe)
    Space.recipe = Space.recipe and Space.recipe[1] or nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Space.combinator then return end
    if not Space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.to_be_processed.entities = This_MOD.to_be_processed.entities or {}
    This_MOD.to_be_processed.entities[Space.entity.name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = GMOD.copy(space.item)
    Sender.icons = { { icon = This_MOD.path_graphics .. "item.png" } }
    Sender.order = "910"

    Sender.name = This_MOD.name_sender
    Sender.place_result = This_MOD.name_sender

    Sender.localised_name = { "", { "entity-name." .. Sender.name } }
    Sender.localised_description = { "", { "entity-description." .. Sender.name } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Sender)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = {
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        type = "roboport",
        name = This_MOD.name_sender,

        localised_name = { "", { "entity-name." .. This_MOD.name_sender } },
        localised_description = { "", { "entity-description." .. This_MOD.name_sender } },

        icons = { { icon = This_MOD.path_graphics .. "item.png" } },

        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },

        max_health = 400,

        energy_usage = "10MW",
        recharge_minimum = "5MJ",
        charging_energy = "5MW",

        base = {
            layers = {
                {
                    filename = This_MOD.path_graphics .. "entity-base.png",
                    width = 232,
                    height = 186,
                    shift = { 0.34375, 0.046875 },
                    scale = 0.5
                },
                {
                    filename = This_MOD.path_graphics .. "entity-base-shadow.png",
                    width = 232,
                    height = 186,
                    shift = { 0.34375, 0.046875 },
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },

        base_animation = {
            layers = {
                {
                    filename = This_MOD.path_graphics .. "entity-antenna.png",
                    width = 108,
                    height = 100,
                    line_length = 8,
                    frame_count = 32,
                    animation_speed = 0.5,
                    shift = { -0.03125, -1.71875 },
                    scale = 0.5,
                },
                {
                    filename = This_MOD.path_graphics .. "entity-antenna-shadow.png",
                    width = 126,
                    height = 98,
                    line_length = 8,
                    frame_count = 32,
                    animation_speed = 0.5,
                    shift = { 3.140625, 0.484375 },
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            }
        },

        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            input_flow_limit = "1GW",
            buffer_capacity = "5MJ"
        },

        circuit_connector = {
            points = {
                shadow = {
                    green = { 0.7, 1.4 },
                    red = { 0.7, 1.4 }
                },
                wire = {
                    green = { 1.2, 0.9 },
                    red = { 1.2, 0.9 }
                }
            }
        },

        minable = {
            mining_time = 0.2,
            results = { {
                type = "item",
                name = This_MOD.name_sender,
                amount = 1
            } }
        },

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        dying_explosion = "medium-explosion",
        corpse = "big-remnants",
        flags = { "placeable-player", "player-creation" },

        logistics_radius = 0,
        robot_slots_count = 0,
        construction_radius = 0,
        material_slots_count = 0,
        charge_approach_distance = 0,

        drawing_box_vertical_extension = 1,
        draw_logistic_radius_visualization = false,
        draw_construction_radius_visualization = false,

        radar_range = space.entity.max_distance_of_nearby_sector_revealed or 1,
        request_to_open_door_timeout = 15,
        spawn_and_station_height = -0.1,
        circuit_wire_max_distance = 10,

        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },

        working_sound = {
            sound = {
                filename = "__base__/sound/roboport-working.ogg",
                volume = 0.6
            },
            max_sounds_per_type = 3,
            audible_distance_modifier = 0.5,
            probability = 1 / (15 * 60)
        },

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar los conectores para que se vean bien
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variables a usar
    local Graphics = "__base__/graphics/entity/circuit-connector/ccm-universal-"
    local X = 1.1
    local Y = 0.5

    --- Cambiar los valores
    Sender.circuit_connector = {
        sprites = {
            connector_main = {
                filename = Graphics .. '04a-base-sequence.png',
                priority = 'low',
                width = 52,
                height = 50,
                scale = 0.5,
                x = 104,
                y = 150,
                shift = { 0.09375 + X, 0.203125 + Y }
            },
            connector_shadow = {
                filename = Graphics .. '04b-base-shadow-sequence.png',
                priority = 'low',
                draw_as_shadow = true,
                width = 60,
                height = 46,
                scale = 0.5,
                x = 120,
                y = 138,
                shift = { 0.3125 + X, 0.3125 + Y }
            },
            wire_pins = {
                filename = Graphics .. '04c-wire-sequence.png',
                priority = 'low',
                width = 62,
                height = 58,
                scale = 0.5,
                x = 124,
                y = 174,
                shift = { 0.09375 + X, 0.203125 + Y }
            },
            wire_pins_shadow = {
                filename = Graphics .. '04d-wire-shadow-sequence.png',
                priority = 'low',
                draw_as_shadow = true,
                width = 68,
                height = 54,
                scale = 0.5,
                x = 136,
                y = 162,
                shift = { 0.390625 + X, 0.34375 + Y }
            },
            led_blue = {
                filename = Graphics .. '04e-blue-LED-on-sequence.png',
                priority = 'low',
                draw_as_glow = true,
                width = 60,
                height = 60,
                scale = 0.5,
                x = 120,
                y = 180,
                shift = { 0.09375 + X, 0.171875 + Y }
            },
            led_blue_off = {
                filename = Graphics .. '04f-blue-LED-off-sequence.png',
                priority = 'low',
                width = 46,
                height = 44,
                scale = 0.5,
                x = 92,
                y = 132,
                shift = { 0.09375 + X, 0.171875 + Y }
            },
            led_green = {
                filename = Graphics .. '04h-green-LED-sequence.png',
                priority = 'low',
                draw_as_glow = true,
                width = 48,
                height = 46,
                scale = 0.5,
                x = 96,
                y = 138,
                shift = { 0.09375 + X, 0.171875 + Y }
            },
            led_red = {
                filename = Graphics .. '04i-red-LED-sequence.png',
                priority = 'low',
                draw_as_glow = true,
                width = 48,
                height = 46,
                scale = 0.5,
                x = 96,
                y = 138,
                shift = { 0.09375 + X, 0.171875 + Y }
            },
            led_light = {
                intensity = 0,
                size = 0.9
            },
            blue_led_light_offset = { 0.09375 + X, 0.453125 + Y },
            red_green_led_light_offset = { 0.09375 + X, 0.359375 + Y }
        },
        points = {
            wire = {
                red = { 0.34375 + X, 0.203125 + Y },
                green = { 0.40625 + X, 0.421875 + Y }
            },
            shadow = {
                red = { 0.859375 + X, 0.546875 + Y },
                green = { 0.671875 + X, 0.546875 + Y }
            }
        }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Sender)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = {}
    Sender.type = "recipe"
    Sender.name = This_MOD.name_sender
    Sender.energy_required = 10
    Sender.enabled = false
    Sender.subgroup = GMOD.items[This_MOD.name_sender].subgroup
    Sender.order = GMOD.items[This_MOD.name_sender].order
    Sender.ingredients = {
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "battery",              amount = 20 },
        { type = "item", name = "steel-plate",          amount = 10 },
        { type = "item", name = "electric-engine-unit", amount = 10 },
    }
    Sender.results = { {
        type = "item",
        name = This_MOD.name_sender,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Sender)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Tecnología base
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Tech = {
        type = "technology",
        name = This_MOD.name_tech,
        localised_name = { "", { "technology-name." .. This_MOD.prefix .. "transmission" } },
        localised_description = { "", { "technology-description." .. This_MOD.prefix .. "transmission" } },
        effects = { {
            type = "unlock-recipe", recipe = This_MOD.name_sender
        } },
        icons = { {
            icon = This_MOD.path_graphics .. "tech.png",
            icon_size = 256
        } },
        order = "e-g",
        prerequisites = {
            "processing-unit",
            "electric-engine",
            "circuit-network"
        },
        unit = {
            count = 100,
            time = 30,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
                mods["space-age"] and { "space-science-pack", 1 } or nil
            }
        }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
--- [ Valores a usar en control.lua ] ---
---------------------------------------------------------------------------------------------------

function This_MOD.load_styles()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

    --- Renombrar
    local Styles = data.raw["gui-style"].default

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Multiuso
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "flow_vertival_8"] = {
        type = "vertical_flow_style",
        vertical_spacing = 8
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cabeza
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "flow_head"] = {
        type = "horizontal_flow_style",
        horizontal_spacing = 8,
        bottom_padding = 7
    }

    Styles[Prefix .. "label_title"] = {
        type = "label_style",
        parent = "frame_title",
        button_padding = 3,
        top_margin = -3
    }

    Styles[Prefix .. "empty_widget"] = {
        type = "empty_widget_style",
        parent = "draggable_space",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        height = 24
    }

    Styles[Prefix .. "button_close"] = {
        type = "button_style",
        parent = "close_button",
        left_click_sound = "__core__/sound/gui-tool-button.ogg",
        padding = 2,
        margin = 0,
        size = 24
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cuerpo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "frame_entity"] = {
        type = "frame_style",
        parent = "entity_frame",
        padding = 0
    }

    Styles[Prefix .. "frame_body"] = {
        type = "frame_style",
        parent = "entity_frame",
        padding = 4
    }

    Styles[Prefix .. "drop_down_channels"] = {
        type = "dropdown_style",
        parent = "dropdown",
        list_box_style = {
            type = "list_box_style",
            maximal_height = 320,
            item_style = {
                type = "button_style",
                parent = "list_box_item",
                left_click_sound = "__core__/sound/wire-connect-pole.ogg",
            },
        },
        width = 296 + 32
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "button_red"] = {
        type = "button_style",
        parent = "tool_button_red",
        left_click_sound = "__core__/sound/gui-tool-button.ogg",
        padding = 0,
        margin = 0,
        size = 28
    }

    Styles[Prefix .. "button_green"] = {
        type = "button_style",
        parent = "tool_button_green",
        left_click_sound = This_MOD.path_sound .. "empty_audio.ogg",
        padding = 0,
        margin = 0,
        size = 28
    }

    Styles[Prefix .. "button_blue"] = {
        type = "button_style",
        parent = "tool_button_blue",
        left_click_sound = "__core__/sound/gui-tool-button.ogg",
        padding = 0,
        margin = 0,
        size = 28
    }

    Styles[Prefix .. "button_add"] = {
        type = "button_style",
        parent = Prefix .. "button_blue",
        left_click_sound = "__core__/sound/wire-connect-pole.ogg",
    }

    Styles[Prefix .. "button"] = {
        type = "button_style",
        parent = "button",
        left_click_sound = "__core__/sound/gui-tool-button.ogg",
        top_margin = 1,
        padding = 0,
        size = 28
    }

    Styles[Prefix .. "stretchable_textfield"] = {
        type = "textbox_style",
        width = 296
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.load_icon()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Name = GMOD.name .. "-icon"
    if data.raw["virtual-signal"][Name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear la señal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend({
        type = "virtual-signal",
        name = Name,
        localised_name = "",
        icon = This_MOD.path_graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.load_sound()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend({
        type = "sound",
        name = "gui_tool_button",
        filename = "__core__/sound/gui-tool-button.ogg",
        volume = 1.0
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------------------------------
