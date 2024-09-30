import sys
import pandas as pd
import matplotlib.pyplot as plt

csv_file = sys.argv[1]
graph_title = sys.argv[2]
output_file = sys.argv[3]

df = pd.read_csv(csv_file, header=None)
plt.plot(df[0], df[1], linestyle='-', color='r', linewidth=0.5)
plt.xlabel('Time (s)')
plt.ylabel('Packets/1s')
plt.title(graph_title)
plt.savefig(output_file, dpi=1200)