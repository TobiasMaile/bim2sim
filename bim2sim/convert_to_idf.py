import tempfile
from pathlib import Path

import bim2sim
from bim2sim import Project, run_project, ConsoleDecisionHandler
from bim2sim.utilities.types import IFCDomain

import sys

def run(ifc_path, epw_path, ep_install_path = "/usr/local/bin/energyplus"):
    """Run a building performance simulation with the EnergyPlus backend.

    This example runs a BPS with the EnergyPlus backend. Specifies project
    directory and location of the IFC file. Then, it creates a bim2sim
    project with the EnergyPlus backend. Simulation settings are specified
    (EnergyPlus location needs to be specified according to your system,
    other settings are set to default if not specified otherwise),
    before the project is executed with the previously specified settings.
    """
    # Create a temp directory for the project, feel free to use a "normal"
    # directory
    project_path = Path(
        tempfile.TemporaryDirectory(prefix='gensim').name)

    # Set the ifc path to use and define which domain the IFC belongs to
    ifc_paths = {
        IFCDomain.arch:
            Path(ifc_path),
    }

    # Create a project including the folder structure for the project with
    # energyplus as backend
    project = Project.create(project_path, ifc_paths, 'energyplus')

    # set weather file data
    project.sim_settings.weather_file_path = (
            Path(epw_path))
    # Set the install path to your EnergyPlus installation according to your
    # system requirements
    project.sim_settings.ep_install_path = ep_install_path

    # run annual simulation for EnergyPlus
    project.sim_settings.run_full_simulation = False
    project.sim_settings.system_sizing = False
    project.sim_settings.run_for_sizing_periods = False
    project.sim_settings.run_for_weather_period = False

    # Set other simulation settings, otherwise all settings are set to default

    # Run the project with the ConsoleDecisionHandler. This allows interactive
    # input to answer upcoming questions regarding the imported IFC.
    run_project(project, ConsoleDecisionHandler())

if __name__ == '__main__':
    if len(sys.argv) > 3:
        run(sys.argv[1], sys.argv[2], sys.argv[3])
    elif len(sys.argv) > 2:
        run(sys.argv[1], sys.argv[2])
    elif len(sys.argv) > 1:
        print("Please provide two files, IFC and EPW not just one")
    else:
        print("Please provide two files, IFC and EPW")


    #run("F:/Repos/bim2sim/test/resources/arch/ifc/AC20-FZK-Haus.ifc", "F:/Repos/bim2sim/test/resources/weather_files/DEU_NW_Aachen.105010_TMYx.epw")