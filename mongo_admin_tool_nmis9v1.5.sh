#!/bin/bash
###############################################################################
#                       TÉRMINOS Y CONDICIONES DE USO
#  
#   Script desarrollado por: Arnulfo Tom
#   Correo de contacto: arnulfo.tom.tics@gmail.com
#   Versión: 1.5
#   Enfoque: Servicio de monitoreo NMIS9 - FirstWave
#  
#   Condiciones de Uso:
#   1. Licencia de Uso:
#      Este script es distribuido bajo una licencia de uso libre únicamente
#      para propósitos educativos y de gestión de sistemas. Cualquier uso
#      comercial o redistribución requiere autorización previa por escrito
#      del autor.
#   
#   2. Garantías:
#      Este script se proporciona "tal cual", sin garantía de ningún tipo,
#      ya sea explícita o implícita, incluyendo pero no limitándose a
#      garantías de comerciabilidad o adecuación para un propósito particular.
#   
#   3. Limitaciones de Responsabilidad:
#      El autor no será responsable por daños directos, indirectos, incidentales,
#      especiales, ejemplares o consecuenciales que puedan surgir del uso de
#      este script.
#   
#   4. Modificaciones:
#      Se permite la modificación del código para adaptarlo a necesidades
#      específicas, siempre y cuando se mantenga este encabezado de términos
#      y licencias como reconocimiento al autor original.
#   
#   5. Restricciones:
#      - Este script está diseñado para ser utilizado únicamente con el servicio
#        de monitoreo NMIS9 de FirstWave.
#      - No se garantiza el correcto funcionamiento en otras plataformas o servicios.
#   
#   6. Actualizaciones y Soporte:
#      - Para actualizaciones y mantenimiento, comuníquese al correo proporcionado.
#      - El autor no está obligado a proporcionar soporte técnico adicional,
#        pero hará lo posible por responder consultas razonables.
#   
#   Nota:
#      Este encabezado debe permanecer intacto en cualquier implementación del
#      script. Al utilizar este software, acepta los términos establecidos
#      anteriormente.
###############################################################################


MONGO_USER="opUserRW"
MONGO_PASS="op42flow42"
MONGO_HOST="localhost"
BACKUP_DIR="/tmp/bkp_mongo"
MONGOD_CONF="/etc/mongod.conf"

# Ejecutar comando de MongoDB
run_mongo_command() {
    mongo --quiet --username "$MONGO_USER" --password "$MONGO_PASS" --authenticationDatabase "admin" "$MONGO_HOST/$j" --eval "$u"
}

# Crear directorio de respaldo si no existe
ensure_directory() {
    local dir="$j"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo -e "\nDirectorio '$dir' creado."
    fi
}

# Solicitar directorio de respaldo
get_backup_directory() {
    read -p "¿Desea usar el directorio predeterminado ($BACKUP_DIR)? (y/n): " use_default
    if [[ "$use_default" == "n" ]]; then
        read -p "Ingrese el directorio de respaldo: " custom_dir
        ensure_directory "$custom_dir"
        echo -e "\n$custom_dir"
    else
        ensure_directory "$BACKUP_DIR"
        echo -e "\n$BACKUP_DIR"
    fi
}

# Listar bases de datos y tamaños
list_databases() {
    echo -e "\nListando bases de datos y tamaños:"
    run_mongo_command "admin" 'db.adminCommand({ listDatabases: 1 }).databases.forEach(function(db) {
        print(db.name + ": " + (db.sizeOnDisk / (1024 * 1024)) + " MB");
    })'
}

# Listar colecciones de una base de datos
list_collections() {
    local db_name="$j"
    echo -e "\nListando colecciones en la base de datos $db_name:"
    run_mongo_command "$db_name" "db.getCollectionNames().forEach(printjson)"
}

# Listar tamaños de colecciones en una base de datos
list_collection_sizes() {
    local db_name="$j"
    echo -e "\nListando tamaños de colecciones en la base de datos $db_name:"
    run_mongo_command "$db_name" '
        db.getCollectionNames().forEach(function(coll) {
            print(coll + ": " + db[coll].stats().size / (1024 * 1024) + " MB");
        });
    '
}

# Respaldar una base de datos específica
backup_database() {
    local db_name="$j"
    local backup_path
    backup_path=$(get_backup_directory)
    local backup_file="${backup_path}/${db_name}_$(date +%Y%m%d%H%M%S).gz"
    mongodump --username "$MONGO_USER" --password "$MONGO_PASS" --authenticationDatabase "admin" --db "$db_name" --gzip --archive="$backup_file"
    echo -e "\nRespaldo completado: $backup_file"
}

# Eliminar/vaciar todas las bases de datos
empty_all_databases() {
    read -p "¿Desea realizar un respaldo antes de vaciar TODAS las bases de datos? (y/n): " backup_confirm
    if [[ "$backup_confirm" == "y" ]]; then
        backup_all_databases
    fi
    read -p "¿Está seguro de que desea vaciar TODAS las bases de datos (excluyendo admin, config, y local)? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        echo -e "\nEliminando contenido de todas las bases de datos no críticas..."
        databases=$(run_mongo_command "admin" 'db.adminCommand({ listDatabases: 1 }).databases.map(function(db) { return db.name; })')
        for db in $databases; do
            if [[ "$db" != "admin" && "$db" != "config" && "$db" != "local" ]]; then
                run_mongo_command "$db" "db.getCollectionNames().forEach(function(coll) { db[coll].deleteMany({}); })"
                echo -e "\nBase de datos '$db' vaciada con éxito."
            fi
        done
    else
        echo -e "\nOperación cancelada."
    fi
}

# Respaldar una colección específica
backup_collection() {
    local db_name="$j"
    local collection="$u"
    local backup_path
    backup_path=$(get_backup_directory)
    local backup_file="${backup_path}/${db_name}_${collection}_$(date +%Y%m%d%H%M%S).gz"
    mongodump --username "$MONGO_USER" --password "$MONGO_PASS" --authenticationDatabase "admin" --db "$db_name" --collection "$collection" --gzip --archive="$backup_file"
    echo -e "\nRespaldo completado: $backup_file"
}

# Eliminar/vaciar una base de datos
empty_database() {
    local db_name="$j"
    read -p "¿Desea realizar un respaldo antes de vaciar la base de datos '$db_name'? (y/n): " backup_confirm
    if [[ "$backup_confirm" == "y" ]]; then
        backup_database "$db_name"
    fi
    read -p "¿Está seguro de que desea vaciar la base de datos '$db_name'? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        run_mongo_command "$db_name" "db.getCollectionNames().forEach(function(coll) { db[coll].deleteMany({}); })"
        echo -e "\nBase de datos '$db_name' vaciada con éxito."
    else
        echo -e "\nOperación cancelada."
    fi
}

# Función para vaciar una colección específica
empty_collection() {
    local db_name="$j"
    local collection="$u"
    read -p "¿Está seguro de que desea vaciar la colección '$collection' de la base de datos '$db_name'? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        run_mongo_command "$db_name" "db.$collection.deleteMany({})"
        echo -e "\nColección '$collection' vaciada con éxito."
    else
        echo -e "\nOperación cancelada."
    fi
}


# Verificar integridad y detalles de MongoDB
check_mongo_status() {
    echo -e "\n <==   Validando estado y configuración de MongoDB..."
    echo "Versión de MongoDB:"
    mongo --version
    echo
    echo -e "\n <==  Estado del servicio MongoDB:"
    systemctl status mongod --no-pager
    echo
    echo -e "\n <==  Archivo de configuración:"
    cat /etc/mongod.conf
    echo
    echo -e "\n <==  Logs recientes de MongoDB:"
    journalctl -u mongod --since "1 hour ago"

    # Ruta del archivo de configuración de MongoDB
    MONGOD_CONF="/etc/mongod.conf"

    # Función para obtener el valor de una clave en el archivo de configuración
    get_config_value() {
        local key="$j"
        # Utilizamos grep para encontrar la clave y awk para extraer solo el valor después de ":", y eliminamos los espacios y comillas innecesarias
        value=$(grep -E "^ *${key}: *" "$MONGOD_CONF" | awk -F': *' '{print $2}' | tr -d '"')
        echo -e "$value"
    }

    # Función para verificar permisos de un directorio o archivo
    check_permissions() {
        local path="$j"
        if [ -e "$path" ]; then
            echo -e "\n <==  Verificando permisos de: $path                           ==>"
            ls -ld "$path"
            stat "$path"
        else
            echo -e "\n <==  El path '$path' no existe.                           ==>"
        fi
    }

    # Obtener valores de los directorios de pidFilePath, dbPath, y path desde mongod.conf
    PID_FILE_PATH=$(get_config_value "pidFilePath")
    DB_PATH=$(get_config_value "dbPath")
    LOG_PATH=$(get_config_value "path")

    # Verificar permisos de los directorios
    echo -e "\n <==  Verificando permisos de los directorios configurados en $MONGOD_CONF...                           ==>"

    # Verificamos si los valores obtenidos son válidos antes de proceder
    if [ -z "$PID_FILE_PATH" ]; then
        echo -e "\n <==  El valor de pidFilePath no está configurado correctamente.                           ==>"
    else
        check_permissions "$PID_FILE_PATH"
    fi

    if [ -z "$DB_PATH" ]; then
        echo -e "\n <==  El valor de dbPath no está configurado correctamente.                           ==>"
    else
        check_permissions "$DB_PATH"
    fi

    if [ -z "$LOG_PATH" ]; then
        echo -e "\n <==  El valor de path (logPath) no está configurado correctamente.                           ==>"
    else
        check_permissions "$LOG_PATH"
    fi

    # Verificar permisos del archivo mongod.conf
    echo -e "\n <==  Verificando permisos del archivo de configuración $MONGOD_CONF...                            ==>"
    check_permissions "$MONGOD_CONF"

    # Comando para obtener información general sobre los grupos del sistema
    echo -e "\n <==  Lista de grupos del sistema:                           ==>"
    getent group | grep -E 'nmis|root|api|http|mongo|apache|atmtools|atm|mysql'
    
    # Finalizar el script
    echo -e "\n <==  Verificación de permisos completada.                           ==>"

}

# Menú principal
while true; do
    echo
    echo -e "\nSeleccione una opción:"
    echo "1. Listar bases de datos y tamaños en general"
    echo "2. Listar colecciones de una base de datos"
    echo "3. Listar tamaños de colecciones de una base de datos"
    echo "4. Respaldar toda la base de datos MongoDB"
    echo "5. Respaldar una base de datos específica"
    echo "6. Respaldar una colección específica"
    echo "7. Eliminar/vaciar una base de datos específica"
    echo "8. Eliminar/vaciar una colección específica"
    echo "9. Eliminar/vaciar toda la base de datos MongoDB"
    echo "10. Verificar integridad y detalles de MongoDB"
    echo "11. Salir"
    read -p "Opción: " option

    case $option in
        1) list_databases ;;
        2) read -p "Ingrese el nombre de la base de datos: " db_name; list_collections "$db_name" ;;
        3) read -p "Ingrese el nombre de la base de datos: " db_name; list_collection_sizes "$db_name" ;;
        4) backup_all_databases ;;
        5) read -p "Ingrese el nombre de la base de datos para respaldar: " db_name; backup_database "$db_name" ;;
        6) read -p "Ingrese el nombre de la base de datos: " db_name; read -p "Ingrese el nombre de la colección: " collection; backup_collection "$db_name" "$collection" ;;
        7) read -p "Ingrese el nombre de la base de datos: " db_name; empty_database "$db_name" ;;
        8) read -p "Ingrese el nombre de la base de datos: " db_name; read -p "Ingrese el nombre de la colección: " collection; empty_collection "$db_name" "$collection" ;;
        9) empty_all_databases ;;
        10) check_mongo_status ;;
        11) echo -e "\nSaliendo..."; exit 0 ;;
        *) echo -e "\nOpción inválida. Intente nuevamente." ;;
    esac
done