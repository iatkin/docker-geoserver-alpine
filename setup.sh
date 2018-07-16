echo "Removing Default Tomcat Webapps"
rm -rf $CATALINA_HOME/webapps/*

echo "Adding Marlin Rasterizer"
mkdir -p /usr/local/marlin
mv marlin-0.9.2-Unsafe.jar /usr/local/marlin/marlin-0.9.2.jar 

echo "Adding GeoServer"
unzip -qq geoserver-$GS_VERSION-war.zip
unzip -qq -d geoserver geoserver.war
mv geoserver $CATALINA_HOME/webapps/
rm geoserver-$GS_VERSION-war.zip geoserver.war

mkdir -p $GEOSERVER_DATA_DIR
mkdir -p $FOOTPRINTS_DATA_DIR

mv $CATALINA_HOME/webapps/geoserver/data/user_projections $GEOSERVER_DATA_DIR

echo "Adding Symbols"
unzip -qq master.zip
mv WorldWeatherSymbols-master/symbols $GEOSERVER_DATA_DIR/styles/
rm master.zip

if [ "$COMMUNITY_MODULES" = "true" ]; then
    echo "Adding Plug-Ins"
    plugin_count=$(wc -l < plugins)
    i=0
    for f in $(ls *.zip); do
        i=$((i+1))
        echo "($i/$plugin_count) $f"
        unzip -qq -o $f
    done
    mv *.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib 
fi
