import sys
import pandas as pd
import matplotlib.pyplot as plt

# Read command-line arguments
csv_file = sys.argv[1]
graph_title = sys.argv[2]
output_file = sys.argv[3]
victim_address = sys.argv[4]  # Victim address passed as a command-line argument

# Read the CSV file with the first row as the header
df = pd.read_csv(csv_file)

# Normalize the time axis by subtracting the minimum Unix time value
df['UnixTime'] = df['UnixTime'] - df['UnixTime'].min()

# Initialize a user counter
user_counter = 1

# Plot each address (each column after the first one)
for column in df.columns[1:]:
    if column == victim_address:
        label = "Victim"  # Rename the victim address to "Victim"
    else:
        label = f"User {user_counter}"  # Label others as "User n"
        user_counter += 1

    plt.plot(df['UnixTime'], df[column], label=label, linewidth=0.5)

# Set labels and title
plt.xlabel('Time (s)')  # Time in seconds starting from 0
plt.ylabel('Received Messages/1s')
plt.title(graph_title)

# Add a legend to the right of the plot
plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))

# Adjust layout to make room for the legend on the right
plt.tight_layout(rect=[0, 0, 0.75, 1])

# Save the figure to a file
plt.savefig(output_file, dpi=1200, bbox_inches='tight')


