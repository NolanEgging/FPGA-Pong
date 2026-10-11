# FPGA-Pong
FPGA game based off of Atari Pong using Digilent Basys 3. 

## Goals
- Rotary encoder control.
- Active score keeping.
- Alternating serve.
- 640x480 pixel @ 60 Hz VGA display.

## Architecture
- FPGA Dev Board: Digilent Basys 3.
- Main Oscillator: 100 MHz
- System Clock Frequency: 25.2 MHz (based on display).
- Units:
  - VGA Driver
  - Quadrature Decoder
  - Score Keeper
  - Ball Logic
  - Paddle Logic
  - Boarder Handler
  - Game Handler

## Testing

## Conclusion

## References
- https://chipverify.com/systemverilog/systemverilog-datatypes#google_vignette
- https://www.fpga4fun.com/VGA.html
- https://digilent.com/reference/_media/basys3:basys3_rm.pdf
- https://projectf.io/posts/video-timings-vga-720p-1080p/
