#ICL SDK4FPGA

Copyright (C) 2014 by Andrea Suardi <a.suardi@imperial.ac.uk> , Imperial College London.  
Supported by the EPSRC Impact Acceleration grant number EP/K503733/1 

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.001.jpg" width="600px" />
</div>

---

### Why it ?

* ICL SDK4FPGA **enables** researchers and engineers (**with or without FPGA knowhow**) to **build, validate and prototype** mathematical algorithms for **FPGA** based system.
* Users **only** need to **code algorithm** using **C/C++** programming languages.
* **Abstracts low level** FPGA **details** from the users: build a testbench, data access to external FPGA memory or host system ...
* Gives **full control (NOT a black box)** of all project phases (test, build, prototype)

---
### Ecosystem

ICL SDK4FPGA is open source under [GNU Lesser General Public License v3](LICENSE) consisting of:

* **Framework:** TCL scripts and customized design templates (C/C++ and Matlab code) that support the users during in all the project phases.
* **Plugins:** advance features that support the users to enhance their FPGA design productivity. As example, FPGA circuit architecture auto tuning to enable utilization of low power and low cost embedded devices devices preserving algorithm numerical performance.  
* **Example designs:** users application designs built with ICL SDK4FPGA framework. 

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.002.jpg" width="600px" />
</div>

---

### What do I need to set up an algorithm running in FPGA ?

##### Expertise

Usually, users' effort for developing algorithm for FPGA is focused mainly on understanding FPGA architecture and on learning Hardware Description Languages coding styles such as VHDL or Verilog. This know-how has been a specific domain of FPGA geeks for many years, and it has been the main entrance barrier to a widely adoption of FPGA in many different fields.  
However during the last years, High Level Synthesis tools enhancement has closed the gap between FPGA programming requirements and aspiring users know-how by means of an efficient C/C++ FPGA programming approach. ICL SDK4FPGA, adopting this FPGA programming style with an assisted design methodology base on TCL scripts, aims to speared the FPGA use, welcoming users at any levels, both people who has heard about FPGA but has never used it as well as FPGA geeks.

To give an idea about the effort required designing algorithms on an FPGA, the two charts here below give you some numbers based on my personal experience as FPGA designer:

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.004.jpg" width="600px" />
</div>

##### Software

ICL SDK4FPGA is a C/C++ based framework targeting [Xilinx FPGA](www.xilinx.com). We are aware that this is just a starting point, many improvement directions can be taken. As example, OpenCL language support as well as other vendors like [Altera FPGA](www.altera.com) are more then welcome. 
 
The required software is:

* [Vivado Design Suite](http://www.xilinx.com/products/design-tools/vivado/index.htm) 2014.1 with Vivado High-Level Synthesis (a free 30-day Evaluation is available from [Xilinx](http://www.xilinx.com/support/download.html) website)  
* [MathWorks Matlab](http://www.mathworks.co.uk/products/matlab/) 2014a. It has not been tested with previous releases, but I should work. 
* [Mentor Graphics Modelsim](http://www.mentor.com/products/fpga/model) any version supported by Vivado Design Suite. It is required only if a test based on RTL-simulation is executed.


##### Hardware

ICL SDK4FPGA supports all Xilinx 7 Series and Zynq®-7000 FPGA devices. Support also older architectures, but refer to [Xilinx](http://www.xilinx.com/products/design-tools/vivado/integration/esl-design/) website for a complete list. If the design purpose is to prototype the designed IP with an Evaluation Board, only these here below are supported now (we are committed to expand this set):

* [ZedBoard](http://www.zedboard.org/product/zedboard)  Zynq™-7000 Development Board  with  Zynq XC7Z020   
* [MicroZed](http://www.zedboard.org/product/microzed) System-On-Module with  Zynq XC7Z020   
* Xilinx Zynq-7000 All Programmable SoC [ZC706](http://www.xilinx.com/products/boards-and-kits/EK-Z7-ZC706-G.htm) Evaluation Kit with Zynq XC7Z045   
* Xilinx Zynq-7000 All Programmable SoC [ZC702](http://www.xilinx.com/products/boards-and-kits/EK-Z7-ZC702-G.htm) Evaluation Kit with Zynq XC7Z020 


---

### How does it work ?

ICL SDK4FPGA has been designed to be intuitive and to guide the user during all the design phases:  
  
1. Define design specifications (*configuration\_parameters.tcl*)
2. Make a custom template (*make_template.tcl*)
3. Starting from the template, code the algorithm using C/C++ language (*IP design: source code*)
4. Test the algorithm code (*IP design: test c/RTL simulation*)
5. Build the algorithm code (*IP design: build*)
6. Build the algorithm on an FPGA (*IP prototype: build*)
7. Test the algorithm running on an FPGA (*IP prototype: test Hardware In the Loop*)

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.005.jpg" width="600px" />
</div>

Please refer to the [ICL SDK4FPGA user guide](doc/SDK4FPGA_user_guide.md) for a details.