#ICL SDK4FPGA

Copyright (C) 2014 by Andrea Suardi <a.suardi@imperial.ac.uk> , Imperial College London.  
Supported by the EPSRC Impact Acceleration grant number EP/K503733/1 

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.001.jpg" width="600px" />
</div>

---

### Why it ?

* ICL SDK4FPGA **enables** researchers and engineers (**with or without FPGA knowhow**) to **build, validate and prototype** their mathematical algorithms into an **FPGA** based system.
* Users need **only** to **code** their **algorithm** using **C/C++**
* **Abstracts low level** FPGA **details** from the users: build a testbench, access data to external FPGA memory, ...
* Gives **full control (NOT a black box)** of all FPGA project phases (test, build, prototype)

---
### Ecosystem

ICL SDK4FPGA is open source under [GNU Lesser General Public License v3](LICENSE) consisted of:

* **Framework:** TCL scripts and design templates (C/C++ and Matlab code) that support the users in all the project phases.
* **Plugins:** advance features that support the user to create an optimal FPGA design. As example, it would be nice to support FPGA design space exploration, word length optimization, ...
* **Example designs:** users application designs built using ICL SDK4FPGA framework. 

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.002.jpg" width="600px" />
</div>

---

### What do I need to set up an algorithm running in FPGA ?

Usually, the user effort for developing an algorithm on FPGA is focused mainly on the understanding about FPGA architecture and on learning about HDL languages coding (such as VHDL or Verilog). This know-how has been a specific domain of FPGA geeks for many years and it has been the main entrance barrier to the adoption of FPGA.  
However during the last years, High Level Synthesis tools enhancement has closed the gap between FPGA programming requirements and users know-how by means of an efficient C/C++ FPGA programming approach. ICL SDK4FPGA, adopting this recent FPGA programming style with an assisted design methodology base on scripts, aims to speared the FPGA use welcoming users at any levels, who has heard about FPGA but has never used it as well as FPGA geeks.

To give an idea of the effort required designing algorithms on an FPGA, the charts here below give some numbers based on my personal experience as FPGA designer:

<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.004.jpg" width="600px" />
</div>


---

### How does it work ?

ICL SDK4FPGA has been designed to be intuitive and will guide the suer during all the design phases:  
  
1. Define design parameters (*configuration_ parameters.tcl*)  
2. Make a custom template (*make_template.tcl*)
3. Starting from the template, code your algorithm using C/C++ language (*IP design source code*)
4. Test the algorithm code (*IP design: test C/RTL simulation*)
5. Build the algorithm code (*IP design: build*)
6. Build the FPGA circuit (*IP prototype: build*)
7. The the FPGA circuit (*IP prototype: test Hardware In the Loop*)
  
The template is 

[Ecosystem](#design1)




<div style="text-align:center" markdown="1">
<img src="doc/figures/icl_sdk4fpga_images.005.jpg" width="600px" />
</div>

---

### design1

---

### design2

---

### design3

---

### design4

