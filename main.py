import tkinter as tk

class AircraftCalculator:
    def __init__(self, master):
        self.master = master
        master.title("Challenger 650 Weight & Balance Calculator")

        # Aircraft-specific data (example values; update with official data)
        self.empty_weight = 15000.0         # lbs
        self.empty_weight_arm = 315.0         # inches
        self.fuel_density = 6.7               # lbs/gallon (used if fuel_unit=="gallons")
        self.fuel_unit = "lbs"                # "lbs" or "gallons"
        self.fuel_tank_locations = {"Left Wing": 300.0, "Right Wing": 360.0, "Center": 330.0}
        self.lemac_location = 270.0           # Leading edge of MAC (inches)
        self.mac_length = 150.0               # MAC length (inches)
        self.payload_arm = 400.0              # inches

        # Input fields
        self.fuel_entries = {}
        row = 0
        for tank in self.fuel_tank_locations:
            tk.Label(master, text=f"{tank} Fuel ({'Gallons' if self.fuel_unit=='gallons' else 'lbs'}):").grid(row=row, column=0, sticky="e")
            entry = tk.Entry(master)
            entry.grid(row=row, column=1, sticky="w")
            self.fuel_entries[tank] = entry
            row += 1

        tk.Label(master, text="Payload Weight (lbs):").grid(row=row, column=0, sticky="e")
        self.payload_entry = tk.Entry(master)
        self.payload_entry.grid(row=row, column=1, sticky="w")
        row += 1

        tk.Label(master, text=f"Payload Arm (in): {self.payload_arm}").grid(row=row, column=0, columnspan=2)
        row += 1

        self.calculate_button = tk.Button(master, text="Calculate", command=self.calculate)
        self.calculate_button.grid(row=row, column=0, columnspan=2)
        row += 1

        self.total_weight_label = tk.Label(master, text="Total Weight: ")
        self.total_weight_label.grid(row=row, column=0, columnspan=2)
        row += 1

        self.cg_location_label = tk.Label(master, text="CG Location (%MAC): ")  # Changed label
        self.cg_location_label.grid(row=row, column=0, columnspan=2)
        row += 1

        self.trim_setting_label = tk.Label(master, text="Trim Setting: ")
        self.trim_setting_label.grid(row=row, column=0, columnspan=2)

    def calculate(self):
        total_fuel_weight = 0.0
        fuel_moment = 0.0
        for tank, entry in self.fuel_entries.items():
            try:
                fuel_input = float(entry.get())
                fuel_weight = fuel_input * self.fuel_density if self.fuel_unit == "gallons" else fuel_input
                total_fuel_weight += fuel_weight
                fuel_moment += fuel_weight * self.fuel_tank_locations[tank]
            except ValueError:
                self.total_weight_label.config(text="Error: Invalid fuel input")
                return

        try:
            payload_weight = float(self.payload_entry.get())
        except ValueError:
            self.total_weight_label.config(text="Error: Invalid payload input")
            return

        total_weight = self.empty_weight + total_fuel_weight + payload_weight
        total_moment = (self.empty_weight * self.empty_weight_arm) + fuel_moment + (payload_weight * self.payload_arm)
        cg_location = total_moment / total_weight

        # Calculate %MAC
        mac_percent = ((cg_location - self.lemac_location) / self.mac_length) * 100

        trim_setting = self.calculate_trim(cg_location)

        self.total_weight_label.config(text=f"Total Weight: {total_weight:.2f} lbs")
        self.cg_location_label.config(text=f"CG Location: {mac_percent:.2f} %MAC")  #Display %MAC
        self.trim_setting_label.config(text=f"Trim Setting: {trim_setting:.2f} units")

    def calculate_trim(self, cg_location):
        mac_percent = ((cg_location - self.lemac_location) / self.mac_length) * 100
        if mac_percent <= 30.0:
            trim = 1.25 + ((mac_percent - 25.0) / 5.0) * (3.0 - 1.25)
        else:
            trim = 3.0 + ((mac_percent - 30.0) / 5.0) * (5.0 - 3.0)
        return max(1.25, min(trim, 5.0))

if __name__ == "__main__":
    root = tk.Tk()
    AircraftCalculator(root)
    root.mainloop()