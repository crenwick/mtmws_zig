## Project Overview

This repository contains an embedded project targeting the Raspberry Pi Pico (RP2040) for the [Music Thing Workshop System](https://github.com/TomWhitwell/Workshop_Computer/tree/main) Computer.

- **Zig firmware** (`src/main.zig`) - Simple MicroZig-based LED blinker with compile-time GPIO configuration. Twist the main knob to activate the LEDs.

## Architecture

### Zig Project Structure  
- Uses [MicroZig](https://github.com/ZigEmbeddedGroup/microzig/tree/616c8729e4a17a7af842a1699b8d8d0124f707d8) 0.14.2 for embedded development
- Compile-time pin configuration system via `GlobalConfiguration` 
- Twist the main knob to activate LEDs 1-6.

## Developer Setup

- `asdf install` to install zig via [ASDF](https://asdf-vm.com/)

## Build Commands

**Build Zig firmware:**
```bash
zig build
```
Generates: `zig-out/firmware/microzig.uf2`

## Development Notes

- MicroZig dependency: 0.14.2, minimum Zig: 0.14.1
- [Computer: Rev 1 Documentation](https://docs.google.com/document/d/1NsRewxAu9X8dQMUTdN0eeJeRCr0HmU0pUjpKB4gM-xo/edit?usp=sharing)
