#!/bin/bash
# -----------------------------------------------------------------------//
#
# Copyright (C) 2018 Fidus Systems Inc.
#
# Project       : simu
# Author        : Jacob von Chorus
# Created       : 2019-02-15
# -----------------------------------------------------------------------//
# -----------------------------------------------------------------------//
# Description   : Creates dependencies required to run a regression of all testcases               
#               Usage:
#                   cd sim/run/
#                   tclsh create_regression_dependencies.tcl
#   CURRENT TOOL VERSION REQUIREMENTS
#   - Vivado 2018.2
#   - Quartus 18.1 Standard
#   - Questa 10.6d
#   - Redhat 7
#       * Change checks below if versions change.
#
# Updated       : date / author - comments
#-----------------------------------------------------------------------//

# Source licenses.
puts stdout "################################################################"
puts stdout "Checking /export/ssd/common_settings_licenses"
puts stdout "################################################################"
if { ![info exists ::env(LM_LICENSE_FILE)] } {
    puts stdout "ERROR LICENSES NOT SOURCED: source /export/ssd/common_settings/licenses"
    return;
}

# Add vivado 2018.2 to path.
puts stdout "################################################################"
puts stdout "Checking /export/ssd/set_vivado.sh for 2018.2"
puts stdout "################################################################"
if { [catch {exec which vivado} msg] } {
    puts stdout "ERROR NO VIVADO: source /export/ssd/common_settings/set_vivado.sh 2018.2"
    return;
} else {
    # Check version
    if {[regexp -line "2018\\.2" $msg] == 0} {
        puts stdout "ERROR WRONG VIVADO VERSION: Requries 2018.2"
        return;
    }
}

# Add Questa 10.6d to path.
puts stdout "################################################################"
puts stdout "Checking /export/ssd/Mentor/questa10.6d_1/questasim/linux_x86_64 in PATH"
puts stdout "################################################################"
if { [catch {exec which vsim} msg] } {
    puts stdout "ERROR NO VSIM: export PATH=/export/ssd/Mentor/questa_10_6_d/questasim/linux_x86_64:\$PATH"
    return;
}


# Add Quartus 18.1 to path.
puts stdout "################################################################"
puts stdout "Checking /export/ssd/altera/18.1/quartus/sopc_builder/bin in PATH"
puts stdout "Checking /export/ssd/altera/18.1/quartus/bin in PATH"
puts stdout "################################################################"
if { [catch {exec which qsys-generate} msg] } {
    puts stdout "ERROR NO QUARTUS: export PATH=/export/ssd/altera/18.1/quartus/sopc_builder/bin:/export/ssd/altera/18.1/quartus/bin:\$PATH"
    return;
} else {
    # Check version
    if {[regexp -line "18\\.1\\/" $msg] == 0} {
        puts stdout "ERROR WRONG QUARTUS VERSION: Requries 18.1 standard"
        return;
    }
}

######################################################################
# Build IPI example.
puts stdout "################################################################"
puts stdout "Building IPI example design."
puts stdout "################################################################"
cd ../../builds/vivado/projects/
if { ![file exists ipi_example.xpr] } {
    exec >&@stdout vivado -mode batch -source ../../scripts/create_project.tcl
} else {
    puts stdout ">>>>>>IPI EXAMPLE DESIGN ALREADY EXISTS."
}
cd ../../../sim/run

######################################################################
# Build Xilinx VIP
puts stdout "################################################################"
puts stdout "Building Xilinx VIP."
puts stdout "################################################################"
cd ../bfms/xilinx_axi_vip/
if { ![file exists vip_management/vip_management.xpr] } {
    exec >&@stdout vivado -mode batch -source xilinx_axi_vip_project_script.tcl
} else {
    puts stdout ">>>>>>XILINX VIP ALREADY EXISTS."
}
cd ../../run

######################################################################
# Build Intel QSYS example.
puts stdout "################################################################"
puts stdout "Building Intel QSYS example design."
puts stdout "################################################################"
cd ../testcases_envIntel_sv_simMquesta/tc_intel_quartus
if { ![file exists intel_avalon_example_system] } {
    exec >&@stdout bash -c "source gen_tb_cmd"
} else {
    puts stdout ">>>>>>INTEL QSYS EXAMPLE DESIGN ALREADY BUILT."
}
cd ../../run/

######################################################################
# Compile Xilinx VSIM libraries.
puts stdout "################################################################"
puts stdout "Compiling Xilinx IP libraries for Questa."
puts stdout "################################################################"
if { ![file exists xsimlib] } {
    exec >&@stdout vivado -mode batch -notrace -source ../scripts_config/scripts_lib/compile_xilinx_libs.tcl -tclargs ip
} else {
    puts stdout ">>>>>>XILINX IP LIBRARIES FOR QUESTA ALREADY BUILT."
}

puts stdout "################################################################"
puts stdout "FINISHED: Dependencies for regression are complete."
puts stdout "################################################################"
