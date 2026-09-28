# Arduino FreeRTOS (PlatformIO) Simulink Target

Custom Embedded Coder target that generates ERT C code, writes a PlatformIO project, and maps each discrete sample rate to a FreeRTOS task.

## Requirements

- MATLAB R2025b (or later) with Simulink, Simulink Coder, and Embedded Coder
- [PlatformIO Core](https://docs.platformio.org/en/latest/core/installation.html) on the host (`pio` on `PATH`, or the default `~/.platformio/penv` install)
- A PlatformIO-supported board that can run FreeRTOS under the Arduino framework

This target does not require the Simulink Support Package for Arduino Hardware.

## Setup

In MATLAB:

```matlab
cd('c:\projects\Simulink-Arduino-FreeRTOS-PIO')
setup_piofrtos
```

`setup_piofrtos` adds the target to the MATLAB path and regenerates `piofrtos.tlc` and `piofrtos.tmf` from `piofrtos.getOptionTable`.

To rebuild the Simulink library after changing I/O blocks:

```matlab
createArduinoPioLibrary
```

## Common I/O blocks

The **Arduino PIO FreeRTOS / Common** library implements Digital, Analog, and Serial I/O as **Level-2 MATLAB S-functions** (`sfcn/*.m`) with matching TLC for Embedded Coder:

| Block | S-function | Host simulation | Generated code |
| --- | --- | --- | --- |
| Digital Input | `arduinopio_digital_input` | `SimValue` 0/1 | `digitalRead` |
| Digital Output | `arduinopio_digital_output` | no-op | `digitalWrite` |
| Analog Input | `arduinopio_analog_input` | `SimValue` ADC counts | `analogRead` |
| Analog Output | `arduinopio_analog_output` | no-op | `analogWrite` (PWM pins) |
| Serial Receive | `arduinopio_serial_receive` | zeros, status false | `Serial.read` |
| Serial Transmit | `arduinopio_serial_transmit` | no-op | `Serial.write` |

Pin numbers follow the active board map (default Uno R3). Analog Output uses PWM-capable pins.

Generated code calls Arduino APIs (`pinMode`, `digitalRead`, `digitalWrite`, `analogRead`, `analogWrite`, `Serial`) through PlatformIO. This target does not add a separate C lock or mutex layer around those calls.

## Digital IO methods (three codegen paths)

**Common** Digital Input/Output use the Level-2 MATLAB S-function path. Open **Digital IO Methods** in the library to compare the same pin API implemented three ways:

| Method | Simulation | Code generation | Typical files |
| --- | --- | --- | --- |
| Level-2 MATLAB S-function | `.m` `Outputs` method; boolean ports; `SimValue` | Matching `.tlc` inlines `pinMode` / `digitalRead` / `digitalWrite` via `WriteRTW` records | `sfcn/arduinopio_digital_*.m`, `.tlc` |
| MATLAB System object | `stepImpl` when not `coder.target("Rtw")`; boolean output; `SimValue` | `coder.ceval` in `setupImpl` / `stepImpl` via `coder.ExternalDependency` | `matlab/+arduinopio/+blocks/+common/DigitalInput.m`, `DigitalOutput.m` |
| Level-2 C S-function | Compiled mex (`mdlOutputs`); boolean digital input | Matching `.tlc` inlines `pinMode` / `digitalRead` / `digitalWrite` via `WriteRTW` records | `sfcn/arduinopio_digital_*_c.c`, `.tlc` |

Build the C mex files (also used by interrupt blocks) with:

```matlab
buildArduinoPioSFunctions
```

## Use with a model

1. Open a fixed-step discrete model.
2. **Modeling > Model Settings > Code Generation** and select **Arduino FreeRTOS (PlatformIO)** (`piofrtos.tlc`).
3. Open the **PlatformIO** code generation category and set:
   - **PlatformIO platform** — dropdown of known-good platforms (`atmelavr`)
   - **PlatformIO board** — dropdown of known-good boards (**Arduino Uno**, **Arduino Nano**)
   - **PlatformIO framework** — dropdown of known-good frameworks (`arduino`)
   - **Extra libraries** — optional `lib_deps` entries, comma or semicolon separated (AVR defaults to `feilipu/FreeRTOS`)
   - **Serial monitor speed** — passed to `monitor_speed` and `Serial.begin`
   - **Upload after build** — run `pio run -t upload` after a successful build
   - **FreeRTOS task stack (words)** — stack depth passed to `xTaskCreate`
4. Build the model (Ctrl+B). Generated files land in `model_piofrtos_rtw/`:
   - ERT sources
   - `platformio.ini`
   - `main.cpp` (includes the generated model header)
   - `model.mk`, which calls host `pio`

## Sample rates and FreeRTOS

The target forces multitasking, rate-grouped `model_stepN` entry points, and one FreeRTOS task per discrete rate:

- Fastest rate gets the highest priority (`tskIDLE_PRIORITY + N` down to `+ 1`)
- Each task calls its step function in a `vTaskDelayUntil` loop
- Arduino `setup()` initializes the model and creates the tasks
- On ESP32 the Arduino core already runs the scheduler, so `vTaskStartScheduler` is not called
- On other Arduino cores, `setup()` starts the scheduler after creating tasks

Continuous or variable-step models are rejected.

## Board notes

The PlatformIO page lists only known-good combinations. Current boards are **Arduino Uno** (`uno`) and **Arduino Nano** (`nanoatmega328`), both on platform `atmelavr` and framework `arduino`. Choosing a board fills in platform and framework.

AVR cores do not ship FreeRTOS, so **Extra libraries** defaults to:

```text
feilipu/FreeRTOS
```

The default task stack is 192 words, which fits classic ATmega328P SRAM.

## Examples

Every example model selects `piofrtos.tlc` when it is created (`piofrtos.configureModel`). Do not build them with the default GRT Windows target.

```matlab
setup_piofrtos
createArduinoPioExamples
build_all
```

`build_all` recreates the models and generates PlatformIO firmware source into `examples/<model>_piofrtos_rtw/`. Those folders are meant to be committed so the generated C, `main.cpp`, and `platformio.ini` can be browsed without running MATLAB.

| Model | What it shows |
| --- | --- |
| `uno_blink` | Digital output on pin 13 |
| `uno_analog_pwm` | Analog input scaled to PWM |
| `uno_serial` | UART transmit and receive |
| `uno_can` | MCP2515 CAN transmit and receive |
| `piofrtos_multirate` | Two discrete rates mapped to FreeRTOS tasks |

With PlatformIO Core installed you can compile a generated folder directly:

```text
pio run --project-dir examples/uno_blink_piofrtos_rtw
```

The repository also contains optional Arduino I/O blocks (`setupArduinoPioPath`). `setup_piofrtos` puts both the target and those blocks on the MATLAB path.

## Tests

```matlab
setup_piofrtos
runtests('tests')
```
