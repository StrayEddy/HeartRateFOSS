import signal
import sys

from PyQt5 import QtGui, QtCore, QtWidgets
from PyQt5.QtWidgets import QMainWindow, QApplication

import subprocess
import re
from datetime import datetime
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection



class Img(QMainWindow):
    def __init__(self, img_path, parent=None):
        super().__init__(parent)
        self.img_path = img_path
        self.qimg = QtGui.QImage(self.img_path)
        self.setStyleSheet('QMainWindow {background:transparent}')
        self.setWindowFlags(
            QtCore.Qt.WindowType.WindowStaysOnTopHint |
            QtCore.Qt.WindowType.FramelessWindowHint |
            QtCore.Qt.WindowType.WindowTransparentForInput |
            QtCore.Qt.X11BypassWindowManagerHint
        )
        self.setAttribute(QtCore.Qt.WidgetAttribute.WA_TranslucentBackground)

        # Create a QLabel to display the heart rate value
        self.heart_rate_label = QtWidgets.QLabel(self)
        self.heart_rate_label.setGeometry(QtCore.QRect(1920-60, 50, 60, 60))  # Adjust the position and size as needed
        self.heart_rate_label.setStyleSheet('QLabel { color: #00ff00; font-size: 32px; font-weight: bold; }')  # Customize label appearance

        # Set window size
        self.resize(1920, 1080)

        # Initialize Matplotlib figure
        self.fig, self.ax = plt.subplots()

        # Lists to store captured values and corresponding timestamps
        self.captured_values = []
        self.timestamps = []

        # Regular expression pattern to match expected values
        self.pattern = re.compile(r'[0-9a-fA-F]+\s+[0-9a-fA-F]+\s+[0-9a-fA-F]+\s([0-9a-fA-F]{2})+')

        # Open the process
        self.process = subprocess.Popen(["bluetoothctl"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE, text=True)

        # Send commands to the process
        self.process.stdin.write("scan le\n")
        self.process.stdin.flush()

        # Schedule the initial output processing and plot update
        self.process_output()
        self.update_plot()

    def process_output(self):
        try:
            output = self.process.stdout.readline()
            if not output and self.process.poll() is not None:
                QtWidgets.qApp.quit()  # Close the application when the process ends
                return

            match = self.pattern.search(output)
            if match:
                captured_hex_value = match.group(1)
                captured_decimal_value = int(captured_hex_value, 16)
                current_time = datetime.now().strftime("%H:%M:%S")

                # Append captured values and timestamps to the lists
                self.captured_values.append(captured_decimal_value)
                self.timestamps.append(current_time)

                # Save captured value to file (overwrite)
                with open('captured_values.txt', 'w') as f:
                    f.write(f"{captured_decimal_value}\n")
                # Save prolonged captured values to file (append)
                with open('prolonged_captured_values.txt', 'a') as f:
                    f.write(f"{captured_decimal_value}\n")

            # Schedule the next output processing after 10 milliseconds
            QtCore.QTimer.singleShot(10, self.process_output)
        except KeyboardInterrupt:
            QtWidgets.qApp.quit()

    def update_plot(self):
        # Update the heart rate label with the current value
        current_heart_rate = self.captured_values[-1] if self.captured_values else "N/A"
        self.heart_rate_label.setText(f"{current_heart_rate}")

        # Keep only the last 60 values in captured_values
        self.captured_values = self.captured_values[-120:]
        self.timestamps = self.timestamps[-120:]

        # Check if lists are not empty
        if self.captured_values and self.timestamps:
            # Plot captured values against timestamps
            self.ax.clear()  # Clear the previous plot

            cmap = plt.get_cmap('rainbow')
            norm = plt.Normalize(70, 140)
            numerical_timestamps = np.arange(len(self.timestamps))
            points = np.array([numerical_timestamps, self.captured_values]).T.reshape(-1, 1, 2)
            segments = np.concatenate([points[:-1], points[1:]], axis=1)
            lc = LineCollection(segments, cmap=cmap, norm=norm, linewidth=5)
            lc.set_array(self.captured_values)
            self.ax.add_collection(lc)

            # Set x-axis limits based on timestamps
            self.ax.set_xlim(min(numerical_timestamps), max(numerical_timestamps))
            # Set y-axis limits between 60 and 100
            self.ax.set_ylim(70, 140)

            # Customize x-axis ticks and labels to reduce their density
            self.ax.tick_params(axis='x', rotation=45, labelright=True, labelleft=False)  # Rotate labels for better readability

            # Hide x and y axis lines, ticks, and labels
            self.ax.xaxis.set_visible(False)
            self.ax.yaxis.set_visible(False)

            # Hide the frame of the plot
            self.ax.set_frame_on(False)

            # Save the plot with a transparent background
            plt.savefig(self.img_path, transparent=True, dpi=66)

            self.qimg = QtGui.QImage(self.img_path)
            self.repaint()

        # Schedule the next update after 1000 milliseconds (1 second)
        QtCore.QTimer.singleShot(1000, self.update_plot)

    def paintEvent(self, qpaint_event):
        painter = QtGui.QPainter(self)
        top_right_corner = self.rect().topRight()
        painter.drawImage(top_right_corner - QtCore.QPoint(self.qimg.width(), 0), self.qimg)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)  # Set up the signal handler for Ctrl+C

    # Clear prolonged captured file
    with open('prolonged_captured_values.txt', 'w') as f:
        pass

    app = QApplication(sys.argv)
    img_path = 'temp_plot.png'
    window = Img(img_path)
    window.show()

    sys.exit(app.exec_())
