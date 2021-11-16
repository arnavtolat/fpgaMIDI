<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

Project Overview 
* This project contains the source code which allows for a fully-functional, polyphonic MIDI keyboard connected to an FPGA with an audio output. 
* The appendices.pdf contains block diagrams of the logic and state diagrams which served as the logical basis for the VHDL written. 
* This project was implemented on a Basys3 FPGA in Xilinx Vivado 2018

### Built With

* [VHDL](https://www.seas.upenn.edu/~ese171/vhdl/vhdl_primer.html) - The VHSIC Hardware Description Language is a hardware description language that can model the behavior and structure of digital systems at multiple levels of abstraction, ranging from the system level down to that of logic gates, for design entry, documentation, and verification purposes
* [Xilinx Vivado](https://www.xilinx.com/support/download.html) - Vivado Design Suite is a software suite produced by Xilinx for synthesis and analysis of HDL design


<p align="right">(<a href="#top">back to top</a>)</p>

## Project Introduction

The project seeks to create a system which accurately takes the digital inputs from a MIDI keyboard and successfully allows for monophonic and polyphonic sound output. More specifically, we create a system which can take in a three byte digital input from a MIDI keyboard, generated upon key-press and key-release on the keyboard, and use it to generate sine waves corresponding to the notes played. These sine waves, inputted and interpreted one at a time, create monophonic sound. Once summed and normalized, the sine waves generate polyphonic sound, allowing users of the system to play chords.

<p align="right">(<a href="#top">back to top</a>)</p>

## Specifications

The system takes in input from a MIDI keyboard, and outputs the highest key which is pressed on the 7-segment display, along with the sound corresponding to the sine waves generated by the digital analog conversion of the input from the MIDI keyboard. For an annotated image of the system, see Appendix 1.

Inputs
* System clock (default clock speed 100 MHz, downscaled to 24 MHz using the Vivado clock generator)
* MIDI keyboard input, passed in through MIDI to Pmod adapter

Outputs
* 7-segment display output describing the key pressed, or in the event of multiple keys pressed at once, the highest frequency key which is pressed
* Audio output to speaker connected to Pmod AMP2, passed through Pmod DA2 (digital-to-analog converter), Pmod DA2 to AMP2 adapter, and Pmod AMP2

Timing and Clocking Information
* Clock Speed: 24 MHz, chosen to allow adequate clock cycles for phase accumulation and polyphony with 88 notes over 7 octave intervals.
* Sampling Rate: 48 kHz, chosen for easier arithmetic and to allow for high-quality audio output (default CD sampling rate is 44.1 kHz).

<p align="right">(<a href="#top">back to top</a>)</p>

## Operating Instructions

In order to set up and run the circuit, one must complete the following steps. For an image of a correctly connected circuit, see Appendix 1:
1. Turn on the Alesis Q25 MIDI keyboard and connect its MIDI output to the MIDI to Pmod adapter using a male-male MIDI cable. This will serve as the MIDI input to the Basys3 Artix-7 FPGA board
  a. Plug the MIDI to Pmod adapter into the top row of the JB input of the Basys3.
    i. On the block diagram, this allows for data input to the midi_iport
2. Connect the Basys3 Artix-7 FPGA board to a computer using a MicroUSB cable,
plugging the MicroUSB end into the Basys3 Artix-7 FPGA board and the USB end into the computer
  a. Using Xilinx Vivado software, follow the prompts to auto-connect to hardware target to connect to the board.
  b. Then, press the program hardware target to program the board with the designed system.
3. Connect the speaker output to the Basys3 Artix-7 FPGA board as follows:
  a. Connect the Pmod DA2 (digital-to-analog converter) to the top row of
Basys3 port JA
  b. Connect the Pmod DA2 to AMP2 adapter to the DA2
  c. Connect the Pmod AMP2 to the DA2 to AMP2 adapter
  d. Connect the speaker’s AUX input to the AUX port on the AMP2 adapter
    i. The data output to a speaker connected to Pmod DA2 by way of the DA2 to AMP2 adapter and AMP2 is represented by v_out on the block diagram.

If these instructions are followed correctly, the user should expect to hear a sound once a key is pressed on the MIDI keyboard. The user should also see the value of the key they are pressing on the Basys3’s 7-segment display. If the user pressed multiple keys at the same time, the user should expect to see the value of the highest key which they press, and expect to hear a polyphonic “chord” sound consisting of the sounds of the keys which they pressed in unison.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
