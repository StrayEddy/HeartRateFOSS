import matplotlib.pyplot as plt

# Your data
with open("prolonged_captured_values.txt", "r") as file:
    y_values = [int(line.strip()) for line in file]

# Generating x-axis values based on the index of y_values
x_values = range(1, len(y_values) + 1)

# Plot
plt.plot(x_values, y_values, marker='o', linestyle='-')
plt.xlabel('Time Step')
plt.ylabel('Value')
plt.title('Plot of the given values')
plt.grid(True)
plt.show()
