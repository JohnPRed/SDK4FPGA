#ICL SDK4FPGA

Copyright (C) 2014 by Andrea Suardi <a.suardi@imperial.ac.uk> , Imperial College London.  
Supported by the EPSRC Impact Acceleration grant number EP/K503733/1 

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.001.jpg" width="600px" />
</div>

---

### Why ICL SDK4FPGA ?

* **Enables** researchers and engineers (**with or without FPGA knowhow**) to **build, validate and prototype** algorithms for **FPGA** based system.
* Users **only** need to **code algorithm** using **C/C++** programming languages.
* **Abstracts low level** FPGA **details** from the users: build a testbench, data access to external FPGA memory or host system ...
* Gives **full control (it is NOT a black box)** of all project phases (design, validation, prototyping)

---
### Ecosystem

ICL SDK4FPGA is open source under [GNU Lesser General Public License v3](LICENSE) consisting of:

* **Framework:** TCL scripts and customised design templates (C/C++ and Matlab code) that support the users during all the project phases.
* **Plugins:** advance features that enhance users' FPGA design productivity. As example, auto tuning of FPGA circuit architecture to target low power and low cost embedded devices devices preserving algorithm numerical performance.  
* **Example designs:** application designs built on ICL SDK4FPGA framework. 

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.002.jpg" width="600px" />
</div>

---

### What do I need to set up an algorithm running in FPGA ?

##### Expertise

Usually, users' effort developing algorithm for FPGA is mainly focused on understanding the FPGA architecture and on learning Hardware Description Languages (such as VHDL or Verilog) coding styles. This know-how has been a specific domain of "FPGA geeks" for many years, and it has been the main entrance barrier to a widely adoption of FPGA in many different fields.  
However during the last years, High Level Synthesis tools enhancement has closed the gap between FPGA programming requirements and aspiring users know-how by means of an efficient C/C++ FPGA programming approach. ICL SDK4FPGA, adopting this programming style in conjunction with an assisted design methodology base on TCL scripts, aims to speared the FPGA use, welcoming users at any levels. People who have already heard about FPGA features but have never used it, as well as "FPGA geeks".

To give an idea about the effort required designing algorithms on an FPGA, the two charts here below give you some numbers based on my personal experience as FPGA engineer:

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.004.jpg" width="600px" />
</div>

##### Software

ICL SDK4FPGA is a C/C++ based framework targeting [Xilinx FPGA](www.xilinx.com). We are aware that this is just a starting point, many improvement directions can be taken. As example, OpenCL language as well as other vendors [Altera FPGA](www.altera.com) support are more then welcome. 
 
The required software is:

* [Vivado Design Suite](http://www.xilinx.com/products/design-tools/vivado/index.htm) 2014.1 with Vivado High-Level Synthesis (a free 30-day Evaluation is available from [Xilinx](http://www.xilinx.com/support/download.html) website)  
* [MathWorks Matlab](http://www.mathworks.co.uk/products/matlab/) 2014a under Window and Linux. It has not been tested with previous releases, but there are good chances that it will work. 
* [Mentor Graphics Modelsim](http://www.mentor.com/products/fpga/model) any version supported by Vivado Design Suite. It is required only if a test based on RTL-simulation based on modelsim is done.


##### Hardware

ICL SDK4FPGA supports all Xilinx 7 Series and Zynq®-7000 FPGA devices. It supports also older architectures. Please refer to [Xilinx](http://www.xilinx.com/products/design-tools/vivado/integration/esl-design/) website for a complete list. If the design purpose is to prototype the algorithm on an Evaluation Board, only the one here below are supported now (we are committed to expand this set):

* [ZedBoard](http://www.zedboard.org/product/zedboard) Zynq™-7000 Development Board  with Zynq XC7Z020   
* [MicroZed](http://www.zedboard.org/product/microzed) System-On-Module with Zynq XC7Z020   
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
6. Build the prototype (*IP prototype: build*)
7. Test prototype (*IP prototype: test Hardware In the Loop*)

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.005.jpg" width="600px" />
</div>

Please refer to the [ICL SDK4FPGA user guide](doc/SDK4FPGA_user_guide.md) for a details.