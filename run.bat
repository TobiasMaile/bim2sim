docker run -dit --name ep epone
docker cp "F:/Repos/bim2sim/test/resources/arch/ifc/AC20-FZK-Haus.ifc" ep:/tmp/
docker cp "F:/Repos/bim2sim/test/resources/weather_files/DEU_NW_Aachen.105010_TMYx.epw" ep:/tmp/
