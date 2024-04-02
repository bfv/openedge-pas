
/app/pas/as/bin/oeprop.sh pas.ROOT.WEB.adapterEnabled=1
echo "\"/web/**\",\"*\",\"permitAll()\"" > /app/pas/as/webapps/ROOT/WEB-INF/oeablSecurity.csv

cat /app/pas/as/webapps/ROOT/WEB-INF/oeablSecurity.csv

/app/pas/start.sh
