import random

hex_values = [f"{random.randint(0, 0xFFFFFFFF):08x}" for _ in range(128)]

with open("../include/param_rf0_data.mem", "w") as file:
    file.write("\n".join(hex_values))

print("✅ Generated 128 random hex values and saved to param_rf0_data.mem")

hex_values = [f"{random.randint(0, 0xFFFFFFFF):08x}" for _ in range(128)]

with open("../include/param_rf1_data.mem", "w") as file:
    file.write("\n".join(hex_values))

print("✅ Generated 128 random hex values and saved to param_rf1_data.mem")

hex_values = [f"{random.randint(0, 0xFFFFFFFF):08x}" for _ in range(128)]

with open("../include/param_rf2_data.mem", "w") as file:
    file.write("\n".join(hex_values))

print("✅ Generated 128 random hex values and saved to param_rf2_data.mem")

hex_values = [f"{random.randint(0, 0xFFFFFFFF):08x}" for _ in range(128)]

with open("../include/param_rf3_data.mem", "w") as file:
    file.write("\n".join(hex_values))

print("✅ Generated 128 random hex values and saved to param_rf3_data.mem")
