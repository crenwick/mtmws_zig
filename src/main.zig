const std = @import("std");
const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const time = rp2xxx.time;
const gpio = rp2xxx.gpio;
const adc = rp2xxx.adc;

const uart = rp2xxx.uart.instance.num(0);
const baud_rate = 115200;
const uart_tx_pin = gpio.num(0);

// Compile-time pin configuration
const pin_config = rp2xxx.pins.GlobalConfiguration{
    // 0/1 are UART
    .GPIO2 = .{ .name = "pulse_in_1", .direction = .in },
    .GPIO3 = .{ .name = "pulse_in_2", .direction = .in },
    // 4 is normalization probe
    // 5/6/7 board identification
    .GPIO8 = .{ .name = "pulse_out_1", .direction = .in },
    .GPIO9 = .{ .name = "pulse_out_2", .direction = .in },
    .GPIO10 = .{ .name = "led_1", .direction = .out },
    .GPIO11 = .{ .name = "led_2", .direction = .out },
    .GPIO12 = .{ .name = "led_3", .direction = .out },
    .GPIO13 = .{ .name = "led_4", .direction = .out },
    .GPIO14 = .{ .name = "led_5", .direction = .out },
    .GPIO15 = .{ .name = "led_6", .direction = .out },
    // 16 & 17 are EEPROM
    // 18, 19, & 20 are DAC/MCP4822 Control
    .GPIO24 = .{ .name = "mux_a", .direction = .out },
    .GPIO25 = .{ .name = "mux_b", .direction = .out },
    .GPIO26 = .{ .name = "audio_r_in", .direction = .in, .function = .ADC0 },
    .GPIO27 = .{ .name = "audio_l_in", .direction = .in, .function = .ADC1 },
    .GPIO28 = .{ .name = "mux_io_1", .direction = .in, .function = .ADC2 },
    .GPIO29 = .{ .name = "mux_io_2", .direction = .in, .function = .ADC3 },
};

const pins = pin_config.pins();

fn setLeds(num_leds: u8) void {
    pins.led_1.put(if (num_leds >= 1) 1 else 0);
    pins.led_2.put(if (num_leds >= 2) 1 else 0);
    pins.led_3.put(if (num_leds >= 3) 1 else 0);
    pins.led_4.put(if (num_leds >= 4) 1 else 0);
    pins.led_5.put(if (num_leds >= 5) 1 else 0);
    pins.led_6.put(if (num_leds >= 6) 1 else 0);
}

pub fn main() !void {
    // init uart logging
    uart_tx_pin.set_function(.uart);
    uart.apply(.{
        .baud_rate = baud_rate,
        .clock_config = rp2xxx.clock_config,
    });
    rp2xxx.uart.init_logger(uart);

    pin_config.apply();

    while (true) : (time.sleep_us(250)) {
        // set the mux and get the output of the main knob
        pins.mux_a.put(0);
        pins.mux_b.put(0);
        const raw_value = adc.convert_one_shot_blocking(pins.mux_io_1) catch {
            std.log.err("ADC conversion failed!", .{});
            continue;
        };

        // Convert to percentage (0-100%)
        const percentage = (@as(f32, @floatFromInt(raw_value)) * 100.0) / 4095.0;

        // Map percentage to integer 0-6
        // 0-14.3% = 0, 14.3-28.6% = 1, 28.6-42.9% = 2, 42.9-57.1% = 3, 57.1-71.4% = 4, 71.4-85.7% = 5, 85.7-100% = 6
        const mapped_value = @as(u8, @intFromFloat(@min(6.0, @floor(percentage / 14.2857))));

        setLeds(mapped_value);

        std.log.info("temp value: {}", .{raw_value});
    }
}
