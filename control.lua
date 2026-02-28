---------------------------------------------------------------------------------------------------
---[ control.lua ]---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Cargar las funciones comunes ]---
---------------------------------------------------------------------------------------------------

require("__" .. "YAIM904-d00b-core" .. "__/control")

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

    --- Validación
    if This_MOD.action then return end

    --- Ejecución de las funciones
    This_MOD.reference_values()
    This_MOD.load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Antenas a revisar por tick
    This_MOD.check_per_tick = 2

    --- Configuración de la superficie
    This_MOD.map_gen_settings = {
        width = 1,
        height = 1,
        property_expression_names = {},
        autoplace_settings = {
            decorative = {
                treat_missing_as_default = false,
                settings = {}
            },
            entity = {
                treat_missing_as_default = false,
                settings = {}
            },
            tile = {
                treat_missing_as_default = false,
                settings = {
                    ["out-of-map"] = {}
                }
            }
        }
    }

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.build = 1
    This_MOD.action.close_force = 2

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Eventos programados ]---
---------------------------------------------------------------------------------------------------

function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones comunes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Al crear la entidad
    script.on_event({
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
        defines.events.on_space_platform_built_entity,
    }, function(event)
        This_MOD.create_entity(This_MOD.create_data(event))
    end)

    --- Abrir o cerrar la interfaz
    script.on_event({
        defines.events.on_gui_opened,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.toggle_gui(This_MOD.create_data(event))
    end)

    --- Al seleccionar otro canal
    script.on_event({
        defines.events.on_gui_selection_state_changed
    }, function(event)
        This_MOD.selection_channel(This_MOD.create_data(event))
    end)

    --- Al hacer clic en algún elemento de la ventana
    script.on_event({
        defines.events.on_gui_click
    }, function(event)
        This_MOD.button_action(This_MOD.create_data(event))
    end)

    --- Al seleccionar o deseleccionar un icon
    script.on_event({
        defines.events.on_gui_elem_changed
    }, function(event)
        This_MOD.add_icon(This_MOD.create_data(event))
    end)

    --- Validar el nuevo nombre al dar ENTER
    script.on_event({
        defines.events.on_gui_confirmed
    }, function(event)
        This_MOD.edit_channel_name(This_MOD.create_data(event))
    end)

    --- Al copiar las entidades
    script.on_event({
        defines.events.on_player_setup_blueprint
    }, function(event)
        This_MOD.create_blueprint(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Muerte y reconstrucción de una entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Muerte de la entidad
    script.on_event({
        defines.events.on_entity_died
    }, function(event)
        This_MOD.before_entity_died(This_MOD.create_data(event))
    end)

    --- Modificar el fantasma de reconstrucción
    script.on_event({
        defines.events.on_post_entity_died
    }, function(event)
        event.entity = event.ghost
        This_MOD.after_entity_died(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones por tiempo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    script.on_event({
        defines.events.on_tick
    }, function()
        --- La entidad tenga energía
        This_MOD.check_power()

        --- Forzar el cierre, en caso de ser necesario
        This_MOD.validate_gui()
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones propias del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Copar la configuración de una antena en otra
    script.on_event({
        defines.events.on_entity_settings_pasted
    }, function(event)
        This_MOD.copy_paste_settings(This_MOD.create_data(event))
    end)

    --- Ocultar la superficie de las fuerzas recién creadas
    script.on_event({
        defines.events.on_force_created
    }, function(event)
        This_MOD.hide_surface(This_MOD.create_data(event))
    end)

    --- Combinar dos forces
    script.on_event({
        defines.events.on_forces_merged
    }, function(event)
        This_MOD.forces_merged(This_MOD.create_data(event))
    end)

    --- Al clonar una antena
    script.on_event({
        defines.events.on_entity_cloned
    }, function(event)
        local Event = GMOD.copy(event)
        Event.entity = event.destination
        This_MOD.create_entity(This_MOD.create_data(Event))
        This_MOD.copy_paste_settings(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.create_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.Entity then return end
    if not GMOD.has_id(Data.Entity.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Variables propias
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Canal por defecto
    if #Data.Channels == 0 then
        This_MOD.get_channel(Data)
    end

    --- Canal de la entidad
    local Channel = Data.Channels[1]
    if Data.Event.tags then
        Channel = This_MOD.get_channel(Data, Data.Event.tags.channel)
    end

    --- Borrar el nombre adicional de la entidad
    Data.Entity.backer_name = ""

    --- Desconectar de la red logistica
    local Control = Data.Entity.get_or_create_control_behavior()
    Control.read_logistics = false

    --- Guardar el nodo con el respectivo canal
    local Node = {}
    Node.entity = Data.Entity
    Node.channel = Channel
    Node.connect = false
    Node.unit_number = Data.Entity.unit_number
    table.insert(Data.Nodes, Node)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Puntos de conexión del nodo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Node.red = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    Node.green = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.toggle_gui(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_close()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.GUI.frame_main then return false end
        if Data.GUI.action == This_MOD.action.build then return false end
        if Data.GUI.action == This_MOD.action.close_force then return true end
        if not Data.Event.element then return false end
        if Data.Event.element == Data.GUI.frame_main then return true end
        if Data.Event.element ~= Data.GUI.button_exit then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function validate_open()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Data.GUI.frame_main then return false end
        if not This_MOD.validate_entity(Data) then return false end

        if Data.Entity.name == "entity-ghost" then
            local Entity = Data.Entity.ghost_prototype
            if GMOD.has_id(Entity.name, This_MOD.id) then
                This_MOD.sound_bad(Data)
                Data.Player.opened = nil
            end
        end

        if not GMOD.has_id(Data.Entity.name, This_MOD.id) then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- En caso de ser necesaria
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.Node then
            This_MOD.create_entity({
                entity = Data.Entity
            })
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function gui_destroy()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_main.destroy()
        Data.gPlayer.GUI = {}
        Data.GUI = Data.gPlayer.GUI
        Data.Player.opened = nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function gui_build()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el cuadro principal
        Data.GUI.frame_main = {}
        Data.GUI.frame_main.type = "frame"
        Data.GUI.frame_main.name = "frame_main"
        Data.GUI.frame_main.direction = "vertical"
        Data.GUI.frame_main = Data.Player.gui.screen.add(Data.GUI.frame_main)
        Data.GUI.frame_main.style = "frame"
        Data.GUI.frame_main.auto_center = true

        --- Indicar que la ventana esta abierta
        --- Cerrar la ventana al abrir otra ventana, presionar E o Esc
        Data.Player.opened = Data.GUI.frame_main

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor de la cabeza
        Data.GUI.flow_head = {}
        Data.GUI.flow_head.type = "flow"
        Data.GUI.flow_head.name = "flow_head"
        Data.GUI.flow_head.direction = "horizontal"
        Data.GUI.flow_head = Data.GUI.frame_main.add(Data.GUI.flow_head)
        Data.GUI.flow_head.style = Prefix .. "flow_head"

        --- Etiqueta con el titulo
        Data.GUI.label_title = {}
        Data.GUI.label_title.type = "label"
        Data.GUI.label_title.name = "title"
        Data.GUI.label_title.caption = { "entity-name." .. Data.Entity.name }
        Data.GUI.label_title = Data.GUI.flow_head.add(Data.GUI.label_title)
        Data.GUI.label_title.style = Prefix .. "label_title"

        --- Indicador para mover la ventana
        Data.GUI.empty_widget_head = {}
        Data.GUI.empty_widget_head.type = "empty-widget"
        Data.GUI.empty_widget_head.name = "empty_widget_head"
        Data.GUI.empty_widget_head = Data.GUI.flow_head.add(Data.GUI.empty_widget_head)
        Data.GUI.empty_widget_head.drag_target = Data.GUI.frame_main
        Data.GUI.empty_widget_head.style = Prefix .. "empty_widget"

        --- Botón de cierre
        Data.GUI.button_exit = {}
        Data.GUI.button_exit.type = "sprite-button"
        Data.GUI.button_exit.name = "button_exit"
        Data.GUI.button_exit.sprite = "utility/close"
        Data.GUI.button_exit.hovered_sprite = "utility/close_black"
        Data.GUI.button_exit.clicked_sprite = "utility/close_black"
        Data.GUI.button_exit = Data.GUI.flow_head.add(Data.GUI.button_exit)
        Data.GUI.button_exit.style = Prefix .. "button_close"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del cuerpo para el inventario
        Data.GUI.flow_items = {}
        Data.GUI.flow_items.type = "flow"
        Data.GUI.flow_items.name = "flow_items"
        Data.GUI.flow_items.direction = "vertical"
        Data.GUI.flow_items = Data.GUI.frame_main.add(Data.GUI.flow_items)
        Data.GUI.flow_items.style = Prefix .. "flow_vertival_8"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_entity = {}
        Data.GUI.frame_entity.type = "frame"
        Data.GUI.frame_entity.name = "frame_entity"
        Data.GUI.frame_entity.direction = "vertical"
        Data.GUI.frame_entity = Data.GUI.flow_items.add(Data.GUI.frame_entity)
        Data.GUI.frame_entity.style = Prefix .. "frame_entity"

        --- Imagen de la entidad
        Data.GUI.entity_preview_entity = {}
        Data.GUI.entity_preview_entity.name = "entity_preview_entity"
        Data.GUI.entity_preview_entity.type = "entity-preview"
        Data.GUI.entity_preview_entity = Data.GUI.frame_entity.add(Data.GUI.entity_preview_entity)
        Data.GUI.entity_preview_entity.style = "wide_entity_button"
        Data.GUI.entity_preview_entity.entity = Data.Entity

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_channel_list = {}
        Data.GUI.frame_channel_list.type = "frame"
        Data.GUI.frame_channel_list.name = "frame_channel_list"
        Data.GUI.frame_channel_list.direction = "horizontal"
        Data.GUI.frame_channel_list = Data.GUI.flow_items.add(Data.GUI.frame_channel_list)
        Data.GUI.frame_channel_list.style = Prefix .. "frame_body"

        --- Barra de movimiento
        Data.GUI.dropdown_channels = {}
        Data.GUI.dropdown_channels.type = "drop-down"
        Data.GUI.dropdown_channels.name = "drop_down_channels"
        Data.GUI.dropdown_channels = Data.GUI.frame_channel_list.add(Data.GUI.dropdown_channels)
        Data.GUI.dropdown_channels.style = Prefix .. "drop_down_channels"

        --- Botón para agregar un canal
        Data.GUI.button_add = {}
        Data.GUI.button_add.type = "sprite-button"
        Data.GUI.button_add.name = "button_add"
        Data.GUI.button_add.sprite = "virtual-signal/shape-cross"
        Data.GUI.button_add = Data.GUI.frame_channel_list.add(Data.GUI.button_add)
        Data.GUI.button_add.style = Prefix .. "button_add"

        --- Botón para aplicar los cambios
        Data.GUI.button_edit = {}
        Data.GUI.button_edit.type = "sprite-button"
        Data.GUI.button_edit.name = "button_edit"
        Data.GUI.button_edit.sprite = "utility/rename_icon"
        Data.GUI.button_edit = Data.GUI.frame_channel_list.add(Data.GUI.button_edit)
        Data.GUI.button_edit.style = Prefix .. "button_blue"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_channel_edit = {}
        Data.GUI.frame_channel_edit.type = "frame"
        Data.GUI.frame_channel_edit.name = "frame_channel_edit"
        Data.GUI.frame_channel_edit.direction = "horizontal"
        Data.GUI.frame_channel_edit = Data.GUI.flow_items.add(Data.GUI.frame_channel_edit)
        Data.GUI.frame_channel_edit.style = Prefix .. "frame_body"
        Data.GUI.frame_channel_edit.visible = false

        --- Nuevo nombre
        Data.GUI.textfield_channel = {}
        Data.GUI.textfield_channel.type = "textfield"
        Data.GUI.textfield_channel.name = "textfield_channel"
        Data.GUI.textfield_channel.text = "xXx"
        Data.GUI.textfield_channel = Data.GUI.frame_channel_edit.add(Data.GUI.textfield_channel)
        Data.GUI.textfield_channel.style = Prefix .. "stretchable_textfield"

        --- Crear la imagen de selección
        Data.GUI.button_icon = {}
        Data.GUI.button_icon.type = "choose-elem-button"
        Data.GUI.button_icon.name = "button_icon"
        Data.GUI.button_icon.elem_type = "signal"
        Data.GUI.button_icon.signal = { type = "virtual", name = GMOD.name .. "-icon" }
        Data.GUI.button_icon = Data.GUI.frame_channel_edit.add(Data.GUI.button_icon)
        Data.GUI.button_icon.style = Prefix .. "button"

        --- Botón para cancelar los cambios
        Data.GUI.button_cancel = {}
        Data.GUI.button_cancel.type = "sprite-button"
        Data.GUI.button_cancel.name = "button_cancel"
        Data.GUI.button_cancel.sprite = "utility/close_fat"
        Data.GUI.button_cancel = Data.GUI.frame_channel_edit.add(Data.GUI.button_cancel)
        Data.GUI.button_cancel.style = Prefix .. "button_red"

        --- Botón para aplicar los cambios
        Data.GUI.button_confirm = {}
        Data.GUI.button_confirm.type = "sprite-button"
        Data.GUI.button_confirm.name = "button_green"
        Data.GUI.button_confirm.sprite = "utility/check_mark_white"
        Data.GUI.button_confirm = Data.GUI.frame_channel_edit.add(Data.GUI.button_confirm)
        Data.GUI.button_confirm.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar los canales
    local function load_channels()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Renombrar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Dropdown = Data.GUI.dropdown_channels

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cargar los canales
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for _, channel in pairs(Data.Channels) do
            Dropdown.add_item(channel.name)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Seleccionar el canal actual
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Dropdown.selected_index = Data.Node.channel.index

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Acción a ejecutar
    if validate_close() then
        gui_destroy()
        This_MOD.sound_close(Data)
    elseif validate_open() then
        Data.GUI.action = This_MOD.action.build
        gui_build()
        load_channels()
        Data.GUI.entity = Data.Entity
        Data.GUI.action = This_MOD.action.none
        This_MOD.sound_open(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.selection_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI.frame_main then return end
    if not This_MOD.validate_entity(Data) then return end
    local Element = Data.Event.element
    local Dropdown = Data.GUI.dropdown_channels
    if Element and Element ~= Dropdown then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar el canal del nodo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Channel = Data.Channels[Dropdown.selected_index]
    This_MOD.set_channel(Data.Node, Channel)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.button_action(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI.frame_main then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cerrar la ventana
    if Data.Event.element == Data.GUI.button_exit then
        This_MOD.toggle_gui(Data)
        return
    end

    --- Cancelar el cambio de nombre o el nuevo canal
    if Data.Event.element == Data.GUI.button_cancel then
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cambiar de frame
        Data.GUI.frame_channel_edit.visible = false
        Data.GUI.frame_channel_list.visible = true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        return
    end

    --- Cambiar el nombre de un canal o agregar un nuevo canal
    if Data.Event.element == Data.GUI.button_confirm then
        This_MOD.edit_channel_name(Data)
        return
    end

    --- Editar el nombre del canal seleccionado
    if Data.Event.element == Data.GUI.button_edit then
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cambiar de frame
        Data.GUI.frame_channel_list.visible = false
        Data.GUI.frame_channel_edit.visible = true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Editar el nombre
        local Textfield = Data.GUI.textfield_channel
        Textfield.text = Data.Node.channel.name

        --- Enfocar nombre
        Data.GUI.textfield_channel.focus()

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        return
    end

    --- Se quiere crear un nuevo canal
    if Data.Event.element == Data.GUI.button_add then
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear un nuevo canal
        local Channel = This_MOD.get_channel(Data)

        --- Cambiar el canal
        This_MOD.set_channel(Data.Node, Channel)

        --- Actualizar el GUI
        local Dropdown = Data.GUI.dropdown_channels
        Dropdown.add_item(Channel.name)
        Dropdown.selected_index = Channel.index

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.add_icon(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.Event.element then return end
    if Data.Event.element ~= Data.GUI.button_icon then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar la selección
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la selección
    local Select = Data.GUI.button_icon.elem_value

    --- Restaurar el icono
    Data.GUI.button_icon.elem_value = {
        type = "virtual",
        name = GMOD.name .. "-icon"
    }

    --- Renombrar
    local Textbox = Data.GUI.textfield_channel

    --- Se intentó limpiar el icono
    if not Select then
        Textbox.focus()
        return
    end

    --- Agregar la imagen seleccionada
    local Text = Textbox.text
    Text = Text .. (function()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variables a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local type = ""

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Detectar el tipo de icono
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Select.type then
            if prototypes.entity[Select.name] then
                type = "entity"
            elseif prototypes.recipe[Select.name] then
                type = "recipe"
            elseif prototypes.fluid[Select.name] then
                type = "fluid"
            elseif prototypes.item[Select.name] then
                type = "item"
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Ajustar el tipo de icono
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Select.type then
            type = Select.type
            if Select.type == "virtual" then
                type = type .. "-signal"
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Devolver el icon en formato de texto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return "[img=" .. type .. "." .. Select.name .. "]"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end)()
    Textbox.text = Text
    Textbox.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.edit_channel_name(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI.frame_main then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Textbox = Data.GUI.textfield_channel
    local Dropdown = Data.GUI.dropdown_channels
    local Index = Dropdown.selected_index

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a usar
    local Name = Textbox.text == ""
    local Channel = GMOD.get_tables(Data.Channels, "name", Textbox.text)
    Channel = Channel and Channel[1] or nil

    --- Valores incorrecto
    if Name or (Channel and Channel.index ~= Index) then
        This_MOD.sound_bad(Data)
        Textbox.focus()
        return
    end

    --- No cambio de nombre
    if Channel and Channel.index == Index then
        Data.GUI.frame_channel_edit.visible = false
        Data.GUI.frame_channel_list.visible = true
        This_MOD.sound_good(Data)
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar el nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Actualizar el nombre
    Data.Node.channel.name = Textbox.text

    --- Actualizar la GUI
    Dropdown.remove_item(Index)
    Dropdown.add_item(Textbox.text, Index)
    Dropdown.selected_index = Data.Node.channel.index

    --- Enfocar la selección
    This_MOD.selection_channel(Data)

    --- Cambiar de frame
    Data.GUI.frame_channel_edit.visible = false
    Data.GUI.frame_channel_list.visible = true

    --- Efecto de sonido
    This_MOD.sound_good(Data)
    Data.GUI.action = nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_blueprint(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable a usar
    local Blueprint = nil

    --- Identificar el tipo de selección
    local Flag_blueprint =
        Data.Player.blueprint_to_setup and
        Data.Player.blueprint_to_setup.valid_for_read

    local Flag_cursor =
        Data.Player.cursor_stack.valid_for_read and
        Data.Player.cursor_stack.is_blueprint

    --- Renombrar la selección
    if Flag_blueprint then
        Blueprint = Data.Player.blueprint_to_setup
    elseif Flag_cursor then
        Blueprint = Data.Player.cursor_stack
    end

    --- Validar la selección
    if not Blueprint then return end
    if not Blueprint.is_blueprint_setup() then return end

    --- Listado de las entidades
    local Entities = Blueprint.get_blueprint_entities()
    if not Entities then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar el canal al que está conectado
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Mapping = Data.Event.mapping.get()
    for _, entity in pairs(Entities or {}) do
        if GMOD.has_id(entity.name, This_MOD.id) then
            local Entity = Mapping[entity.entity_number]
            local Node = GMOD.get_tables(Data.Nodes, "entity", Entity)[1]
            local Tags = { channel = Node.channel.name }
            Blueprint.set_blueprint_entity_tags(entity.entity_number, Tags)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.before_entity_died(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not GMOD.has_id(Data.Entity.name, This_MOD.id) then
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Eliminar la conexión
    Data.Node.red.disconnect_from(Data.Node.channel.red, defines.wire_origin.script)
    Data.Node.green.disconnect_from(Data.Node.channel.green, defines.wire_origin.script)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Información a guardar
    local Info = {}
    Info.unit_number = Data.Node.unit_number
    Info.channel = Data.Node.channel

    --- Guardar la información
    table.insert(Data.Ghosts, Info)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.after_entity_died(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Ghost = Data.Event.ghost or {}
    local Prototype = Data.Event.prototype

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if #Data.Ghosts == 0 then return end
    if not GMOD.has_id(Prototype.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cargar la información relacionada
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for index, info in pairs(Data.Ghosts) do
        if info.unit_number == Data.Event.unit_number then
            Ghost.tags = { channel = info.channel.name }
            table.remove(Data.Ghosts, index)
            break
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.check_power()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Funciones de validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function connection_toggle(Data)
        --- Entidad a modificar
        if not Data.Entity then return end
        if not Data.Entity.valid then return end

        --- Renombrar
        local Node = GMOD.get_tables(Data.Nodes, "entity", Data.Entity)
        if not Node then return end
        Node = Node[1]

        if Node.connect then
            --- Desconectar
            Node.connect = false
            Node.red.disconnect_from(Node.channel.red, defines.wire_origin.script)
            Node.green.disconnect_from(Node.channel.green, defines.wire_origin.script)
        else
            --- Conectar
            Node.connect = true
            Node.red.connect_to(Node.channel.red, false, defines.wire_origin.script)
            Node.green.connect_to(Node.channel.green, false, defines.wire_origin.script)
        end
    end

    local function check_power(Node)
        --- En Factorio 2.0 puede ocurrir que la entidad esté
        --- completamente alimentada, pero debido a algunas
        --- peculiaridades del motor el búfer sólo está lleno
        --- al 96%, por ejemplo.

        --- Umbral de activació: 90%
        local Threshold = 0.9

        --- Variables a usar
        local Energy = Node.entity.energy
        local Buffer = Node.entity.electric_buffer_size
        local Power_satisfied = Energy >= Buffer * Threshold

        --- Acciones
        local Flag = false
        Flag = Flag or Node.connect and not Power_satisfied --- Desconectar
        Flag = Flag or not Node.connect and Power_satisfied --- Conectar
        if Flag then
            local Data = { entity = Node.entity }
            Data = This_MOD.create_data(Data)
            connection_toggle(Data)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar cada antena
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable a usar
    local Data = This_MOD.create_data()
    local Deleted = {}

    --- Validar cada Nodo
    for i = Data.gMOD.check_power, Data.gMOD.check_power + This_MOD.check_per_tick do
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el índice del jugador
        local Node = Data.Nodes[i]
        if not Node then
            Data.gMOD.check_power = 1
            break
        end

        --- Validar que la entidad siga existiendo
        if Node.entity and Node.entity.valid then
            Data.gMOD.check_power = Data.gMOD.check_power + 1
            check_power(Node)
        else
            table.insert(Deleted, 1, Data.gMOD.check_power)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Eliminar a las entidad invalidas
    for _, key in pairs(Deleted) do
        table.remove(Data.Nodes, key)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.validate_gui()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable a usar
    local Data = This_MOD.create_data()
    local Last = Data.gMOD.check_GUI + This_MOD.check_per_tick

    --- Validar cada GUI
    while Data.gMOD.check_GUI <= Last do
        --- Validar el índice del jugador
        local Player_index = Data.Players_index[Data.gMOD.check_GUI]
        if Player_index then
            Data.gMOD.check_GUI = Data.gMOD.check_GUI + 1
        else
            Data.gMOD.check_GUI = 1
            break
        end

        --- Cargar la información del jugador
        local gPlayer = Data.gPlayers[Player_index]

        --- Validar que el jugador tenga un GUI abierta
        if gPlayer.GUI.frame_main and gPlayer.GUI.frame_main.valid then
            --- Agrupar la información a usar
            local pData = This_MOD.create_data({
                entity = gPlayer.GUI.entity,
                player_index = Player_index
            })

            --- Cerrar el GUI de ser necesario
            if This_MOD.validate_entity(pData) then
                This_MOD.validate_distance(pData)
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.copy_paste_settings(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Source = Data.Event.source
    local Destination = Data.Event.destination

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Source.name == "entity-ghost" then return end
    if Destination.name == "entity-ghost" then return end

    if not GMOD.has_id(Source.name, This_MOD.id) then return end
    if not GMOD.has_id(Destination.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Hacer el cambio
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Source = GMOD.get_tables(Data.Nodes, "unit_number", Source.unit_number)[1]
    Destination = GMOD.get_tables(Data.Nodes, "unit_number", Destination.unit_number)[1]
    This_MOD.set_channel(Destination, Source.channel)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.hide_surface(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Surface = This_MOD.get_surface()
    if Surface then
        Data.Event.force.set_surface_hidden(Surface, true)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.forces_merged(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Source = Data.gForces[Data.Event.source_index]
    if not Source then return end
    local Destination = This_MOD.create_data({
        force = Data.Event.destination
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Mover los canales
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Canales a mover
    local Move = {}

    --- Recorrer cada nodo
    for _, node in pairs(Source.nodes) do
        --- Variable a usar
        local Channel

        --- Canal por defecto
        if node.channel.index == 1 then
            Channel = Destination.channels[1]
        else
            --- Buscar el canal actual
            Channel = GMOD.get_tables(
                Destination.channels,
                "name", node.channel.name
            )[1]

            --- Canal a mover
            Move[node.channel.index] = not Channel and node.channel or nil
        end

        --- Mover el nodo
        table.insert(Destination.nodes, node)

        --- Cambiar la conexión
        if not Move[node.channel.index] then
            This_MOD.set_channel(node, Channel)
        end
    end

    --- Mover los canales
    for key, channel in pairs(Move) do
        local Index = #Destination.channels + 1
        Destination.channels[Index] = channel
        Source.channels[key] = nil
        channel.index = Index
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Eliminar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Eliminar los canales
    for _, channel in pairs(Source.channels) do
        channel.entity.destroy()
    end

    --- Eliminar la referencia a la fuerza
    Data.gForces[Data.Event.source_index] = nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Funciones auxiliares ]---
---------------------------------------------------------------------------------------------------

function This_MOD.create_data(event)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Consolidar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Data = GMOD.create_data(event or {}, This_MOD)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Variables globales
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Indice de los jugadores
    Data.gMOD.players_index = Data.gMOD.players_index or {}
    Data.Players_index = Data.gMOD.players_index

    --- Antenas
    Data.gMOD.nodes = Data.gMOD.nodes or {}
    Data.Nodes = Data.gMOD.nodes

    --- Revisar el siguiente bloque de antenas
    Data.gMOD.check_power = Data.gMOD.check_power or 1
    Data.gMOD.check_GUI = Data.gMOD.check_GUI or 1

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.gForce then return Data end
    if not event then return Data end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Variables propias
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Postes / canales
    Data.gForce.channels = Data.gForce.channels or {}
    Data.Channels = Data.gForce.channels

    --- Auxiliar
    Data.gForce.ghosts = Data.gForce.ghosts or {}
    Data.Ghosts = Data.gForce.ghosts

    --- Agregar el jugador al índice
    if Data.Player and not GMOD.get_key(Data.Players_index, Data.Player.index) then
        table.insert(Data.Players_index, Data.Player.index)
    end

    --- Cargar el nodo a tratar
    if Data.Entity or Data.GUI then
        local Entity = Data.Entity or Data.GUI.entity
        Data.Node = GMOD.get_tables(Data.Nodes, "entity", Entity)
        Data.Node = Data.Node and Data.Node[1] or nil
    end

    --- Devolver el consolidado de los datos
    return Data

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.get_surface()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if game.surfaces[This_MOD.prefix .. This_MOD.name] then
        return game.surfaces[This_MOD.prefix .. This_MOD.name]
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear la superficie
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la superficie
    local Surface = game.create_surface(
        This_MOD.prefix .. This_MOD.name,
        This_MOD.map_gen_settings
    )

    --- Crear el espacio a usar
    Surface.request_to_generate_chunks({ 0, 0 }, 1)
    Surface.force_generate_chunk_requests()

    --- Ocultar la superficie de todas las fuerzas
    for _, force in pairs(game.forces) do
        force.set_surface_hidden(Surface, true)
    end

    --- Devolver la superficie
    return Surface

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.get_channel(Data, channel)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Superficie de los canales
    local Surface = This_MOD.get_surface()

    --- Convertir el index en iconos
    if not channel then
        channel = ""
        local Index = tostring(#Data.Channels + 1)
        for n = 1, #Index do
            channel = channel .. "[img=virtual-signal.signal-" .. Index:sub(n, n) .. "]"
        end
    end

    --- Cargar el canal indicado
    local Channel = GMOD.get_tables(Data.Channels, "name", channel)
    if Channel then return Channel[1] end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear un nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el poste
    local Entity = Surface.create_entity({
        name = "small-electric-pole",
        position = { 0, 0 },
        force = Data.Force.name
    })

    --- Desconectar el poste
    local Copper = Entity.get_wire_connector(defines.wire_connector_id.pole_copper, false)
    Copper.disconnect_all(defines.wire_origin.script)

    --- Guardar el nuevo canal
    Channel = {}
    Channel.index = #Data.Channels + 1
    Channel.entity = Entity
    Channel.name = channel
    Channel.red = Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    Channel.green = Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    Data.Channels[Channel.index] = Channel

    --- Devolver el canal indicado
    return Channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.set_channel(node, channel)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if node.channel and node.channel == channel then return end
    if not node.entity.valid then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Hacer le cambio en los cambles
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los cables de canal
    if node.connect then
        --- Desconectar
        node.red.disconnect_from(node.channel.red, defines.wire_origin.script)
        node.green.disconnect_from(node.channel.green, defines.wire_origin.script)

        --- Conectar
        node.red.connect_to(channel.red, false, defines.wire_origin.script)
        node.green.connect_to(channel.green, false, defines.wire_origin.script)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar el canal de la enridad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    node.channel = channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.validate_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cerrado forzado de la ventana de ser necesario
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Flag = false
    Flag = (Data.GUI.entity and Data.GUI.entity.valid)
    Flag = Flag or (Data.Entity and Data.Entity.valid)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Flag then
        if Data.GUI.frame_main then
            Data.GUI.action = This_MOD.action.close_force
            This_MOD.toggle_gui(Data)
        end
        return false
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Aprovado
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    return true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.validate_distance(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local pPos = Data.Player.position
    local ePos = Data.GUI.entity.position
    local Distance_max = Data.Player.build_distance

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Calcular la distancia entre el jugador y la entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local dX = pPos.x - ePos.x
    local dY = pPos.y - ePos.y
    local Distance = math.sqrt(dX * dX + dY * dY) - 1.2

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cerrar el GUI si el jugador está lejos de la entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Distance > Distance_max then
        Data.GUI.action = This_MOD.action.close_force
        This_MOD.toggle_gui(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.sound_good(Data)
    Data.Player.play_sound({ path = "gui_tool_button" })
end

function This_MOD.sound_bad(Data)
    Data.Player.play_sound({ path = "utility/cannot_build" })
end

function This_MOD.sound_open(Data)
    Data.Player.play_sound({ path = "entity-open/decider-combinator" })
end

function This_MOD.sound_close(Data)
    Data.Player.play_sound({ path = "entity-close/decider-combinator" })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------------------------------
