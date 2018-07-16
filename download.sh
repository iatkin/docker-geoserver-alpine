echo "Downloading GeoServer"
wget -q http://downloads.sourceforge.net/project/geoserver/GeoServer/2.13.0/geoserver-${GS_VERSION}-war.zip

echo "Downloading Symbols"
wget -q https://github.com/greenlaw/WorldWeatherSymbols/archive/master.zip

echo "Downloading Marlin"
wget -q https://github.com/bourgesl/marlin-renderer/releases/download/v0_9_2/marlin-0.9.2-Unsafe.jar

if [ "$COMMUNITY_MODULES" == "true" ]; then
    plugin_count=$(wc -l < plugins)
    
    echo "Downloading $plugin_count plug-ins"

    i=0
    for plugin in $(cat plugins)
    do
        i=$((i+1))
        file_name=$(echo $plugin | sed "s/\${GS_VERSION}/${GS_VERSION}/g")
        echo "($i/$plugin_count) $file_name"
        wget -q $file_name
    done
fi
