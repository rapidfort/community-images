auditbeat version
auditbeat keystore create --auto-approve
echo  "admin" | auditbeat keystore add ES_PWD --stdin --force
auditbeat keystore list
auditbeat keystore remove ES_PWD
auditbeat export config
auditbeat export template --es.version 8.13.4
auditbeat export dashboard --id="a7b35890-8baa-11e8-9676-ef67484126fb" --folder=/usr/share/auditbeat > dashboard.json || echo 0
auditbeat help export
auditbeat -e
auditbeat run -e
auditbeat setup --dashboards
auditbeat setup --index-management
auditbeat test config
auditbeat export ilm-policy
auditbeat export index-pattern
auditbeat test output -c auditbeat.yml