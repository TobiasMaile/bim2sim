docker run -dit --name ep epone
docker cp "F:/Repos/bim2sim/test/resources/arch/ifc/AC20-FZK-Haus.ifc" ep:/tmp/
docker cp "F:/Repos/bim2sim/test/resources/weather_files/DEU_NW_Aachen.105010_TMYx.epw" ep:/tmp/
docker exec ep micromamba run -n base python /home/mambauser/bim2sim/bim2sim/convert_to_idf.py /tmp/AC20-FZK-Haus.ifc /tmp/DEU_NW_Aachen.105010_TMYx.epw /usr/local/EnergyPlus-9-4-0/
