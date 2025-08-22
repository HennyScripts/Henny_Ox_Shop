# Henny's Modern OX Shop

A feature-rich, standalone shop script for FiveM, designed for seamless integration with the Overextended (OX) ecosystem. It features a clean, modern, and fully interactive UI, server-authoritative security, and extensive configuration options.

---

## Features

* **Standalone Core:** Works out-of-the-box without requiring ESX, QBX or QBCore, but is compatible with their money systems.
* **Modern UI:** A sleek, responsive, and draggable interface built with HTML, CSS, and JS.
* **`ox_inventory` Ready:** Natively uses `ox_inventory` for giving items and automatically fetches item images from its data files.
* **`ox_target` Integration:** Simple and intuitive interaction with shop NPCs using `ox_target`.
* **Extensive Configuration:** Easily add or modify shops, item categories, prices, NPC models, and map blips in a single config file.
* **Secure by Design:** All purchase and price validations are handled server-side to prevent common client-side exploits.

---

## Dependencies

This script requires the following resources to be installed and started on your server:
* [ox_lib](https://github.com/overextended/ox_lib) (Must be started before this script)
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [ox_target](https://github.com/overextended/ox_target)

---

## Installation

1.  **Download:** Download the `henny_ox_shop` folder from this repository.
2.  **Place in Resources:** Drag and drop the `henny_ox_shop` folder into your server's `resources` directory.
3.  **Edit `server.cfg`:** Add the following line to your `server.cfg` file. Ensure it is started *after* its dependencies.
    ```cfg
    ensure henny_ox_shop
    ```
4.  **Configure:** Open the `config.lua` file and customize the shops and items to your liking (see Configuration section below).
5.  **Restart Server:** Restart your FiveM server, and the shops will be active.

---

## Configuration

All customization is done within the `config.lua` file.


