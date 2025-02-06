--[[ 
   CL650 Weight & Balance (IMGUI version)

   - Requires FlyWithLua NG+ or newer (with IMGUI support).
   - Creates a single toggle macro for a floating window.
   - The window has input fields for fuel/payload and a "Calculate" button.
   - Results (total weight, CG %MAC, trim) are shown in the same window.
--]]

-----------------------------------------
-- 1) GLOBAL VARIABLES & AIRCRAFT DATA
-----------------------------------------
local my_window   = nil
local show_window = false

-- Aircraft-specific data
local empty_weight       = 15000.0   -- lbs
local empty_weight_arm   = 315.0     -- inches
local fuel_density       = 6.7       -- lbs/gallon (used if fuel_unit=="gallons")
local fuel_unit          = "lbs"     -- "lbs" or "gallons"
local lemac_location     = 270.0     -- Leading edge of MAC (inches)
local mac_length         = 150.0     -- MAC length (inches)
local payload_arm        = 400.0     -- Payload arm (inches)

-- Tank arm locations
local left_wing_loc      = 300.0
local right_wing_loc     = 360.0
local center_loc         = 330.0

-- User inputs (fuel/payload)
local left_fuel          = 0.0
local right_fuel         = 0.0
local center_fuel        = 0.0
local payload            = 0.0

-- A string to show result messages after calculation
local calc_message       = ""


-----------------------------------------
-- 2) MACRO: SINGLE TOGGLE
-----------------------------------------
-- Called when user selects the macro
function toggle_window()
    -- If window currently hidden, show it
    if not show_window then
        show_window = true
        if not my_window then
            create_floating_window()
        end
    else
        -- If window currently shown, hide it
        show_window = false
        if my_window then
            float_wnd_destroy(my_window)
            my_window = nil
        end
    end
end

-- Create one macro with a single toggle function
add_macro("CL650 Weight & Balance: Toggle Window", "toggle_window()", "", "")


-----------------------------------------
-- 3) CREATE THE FLOATING WINDOW
-----------------------------------------
function create_floating_window()
    if not SUPPORTS_FLOATING_WINDOWS then
        logMsg("Floating windows not supported by this FlyWithLua version.")
        return
    end

    -- Create a floating window: width=400, height=300, decoration=1, use_imgui=true
    my_window = float_wnd_create(400, 300, 1, true)
    float_wnd_set_title(my_window, "CL650 Weight & Balance")

    -- Assign our IMGUI builder (callback) to draw the UI
    float_wnd_set_imgui_builder(my_window, "on_build_gui")

    -- Optionally, center the window on screen
    if SCREEN_WIDTH and SCREEN_HEIGHT then
        float_wnd_set_position(my_window, (SCREEN_WIDTH - 400)/2,
                                          (SCREEN_HEIGHT - 300)/2)
    end
end


-----------------------------------------
-- 4) CALCULATION FUNCTIONS
-----------------------------------------
local function calculate_trim(cg_location)
    local mac_percent = ((cg_location - lemac_location) / mac_length) * 100
    local trim = 0.0

    -- Simple example interpolation
    if mac_percent <= 30.0 then
        -- Interpolate between 25% => 1.25 and 30% => 3.0
        trim = 1.25 + ((mac_percent - 25.0) / 5.0) * (3.0 - 1.25)
    else
        -- Interpolate between 30% => 3.0 and 35% => 5.0
        trim = 3.0 + ((mac_percent - 30.0) / 5.0) * (5.0 - 3.0)
    end

    -- Clamp 1.25 to 5.0
    return math.max(1.25, math.min(trim, 5.0))
end


local function calculate_wb(lf, rf, cf, pl)
    local total_fuel_weight = 0.0
    local fuel_moment       = 0.0

    -- Build tank table
    local tanks = {
        { qty = lf, arm = left_wing_loc  },
        { qty = rf, arm = right_wing_loc },
        { qty = cf, arm = center_loc     }
    }

    for _, t in ipairs(tanks) do
        local fw = (fuel_unit == "lbs") and t.qty or (t.qty * fuel_density)
        total_fuel_weight = total_fuel_weight + fw
        fuel_moment       = fuel_moment + (fw * t.arm)
    end

    local total_weight = empty_weight + total_fuel_weight + pl
    local total_moment = (empty_weight * empty_weight_arm) + fuel_moment + (pl * payload_arm)
    local cg_location  = total_moment / total_weight

    -- CG in %MAC
    local mac_percent = ((cg_location - lemac_location) / mac_length) * 100

    -- Trim
    local trim_setting = calculate_trim(cg_location)
    return total_weight, mac_percent, trim_setting
end


-----------------------------------------
-- 5) IMGUI GUI BUILDER
-----------------------------------------
function on_build_gui(window_id)
    if not show_window then return end

    -- Title
    imgui.TextUnformatted("Challenger 650 Weight & Balance")

    -- Input for Left Fuel
    local changed_l, new_left = imgui.InputFloat("Left Fuel (lbs)", left_fuel, 0, 0, "%.1f")
    if changed_l then
        left_fuel = math.max(new_left, 0)
    end

    -- Input for Right Fuel
    local changed_r, new_right = imgui.InputFloat("Right Fuel (lbs)", right_fuel, 0, 0, "%.1f")
    if changed_r then
        right_fuel = math.max(new_right, 0)
    end

    -- Input for Center Fuel
    local changed_c, new_center = imgui.InputFloat("Center Fuel (lbs)", center_fuel, 0, 0, "%.1f")
    if changed_c then
        center_fuel = math.max(new_center, 0)
    end

    -- Input for Payload
    local changed_p, new_payload = imgui.InputFloat("Payload (lbs)", payload, 0, 0, "%.1f")
    if changed_p then
        payload = math.max(new_payload, 0)
    end

    -- A bit of spacing
    imgui.Spacing()

    -- Calculate Button
    if imgui.Button("Calculate##wbcalc") then
        local wt, cg, trim = calculate_wb(left_fuel, right_fuel, center_fuel, payload)
        calc_message = string.format("Total Weight: %.2f lbs\nCG: %.2f %%MAC\nTrim: %.2f units",
                                     wt, cg, trim)
    end

    -- If we have a calculation message, display it
    if calc_message ~= "" then
        imgui.Spacing()
        imgui.TextUnformatted(calc_message)
    end
end
