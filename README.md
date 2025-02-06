# CL650 Fuel Weight & CG/Trim Calculator for X-Plane 12

This package provides tools to assist with fuel weight, center of gravity (CG), and trim calculations for the Challenger 650 in X-Plane 12.

## Contents

This package includes:

*   **Desktop Application (Windows):** A standalone desktop application for easy calculations.
*   **In-Game Lua Script:** A FlyWithLua script for in-game use.

## Installation and Usage

### Desktop Application

1.  Navigate to the `/dist` directory.
2.  Run `main.exe`.

### FlyWithLua Script (In-Game)

1.  **Prerequisites:** You must have FlyWithLua installed.  Download it from: [https://forums.x-plane.org/index.php?/files/file/82888-flywithlua-ng-next-generation-plus-edition-for-x-plane-12-win-lin-mac/](https://forums.x-plane.org/index.php?/files/file/82888-flywithlua-ng-next-generation-plus-edition-for-x-plane-12-win-lin-mac/)
2.  Copy the Lua script file to the FlyWithLua scripts folder (usually located within your X-Plane 12 installation).
3.  **In X-Plane 12:**
    *   Go to the `Plugins` menu.
    *   Select `FlyWithLua`.
    *   Choose `Macros`.
    *   The CL650 calculator entry should be listed there. Select it to run.

## Building the Desktop Application (Updating the Script)

If you wish to modify and rebuild the desktop application (main.exe), you can use PyInstaller.

1.  Ensure you have PyInstaller installed: `pip install pyinstaller`
2.  Navigate to the directory containing `main.py`.
3.  Run the following command in your terminal:

    ```bash
    pyinstaller --onefile --windowed main.py
    ```

    *   `--onefile`: Creates a single executable file.
    *   `--windowed`:  Creates a windowed application (no console window).

4.  The resulting executable will be located in the `dist` folder.