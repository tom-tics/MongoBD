Manual del Script de Gestión de MongoDB para NMIS9 - FirstWave 

Este documento sirve como manual para el uso y comprensión del script de gestión de MongoDB diseñado específicamente para trabajar con el servicio de monitoreo NMIS9  de FirstWave . Este script proporciona una serie de funciones útiles para la administración, respaldo, vaciado y verificación de bases de datos en MongoDB. 
Índice 

    Información General 
    Condiciones de Uso 
    Pre-requisitos 
    Configuración Inicial 
    Funcionalidades Principales 
    Instrucciones de Uso 
    Soporte y Actualizaciones 
     

Información General 

Este script fue desarrollado por Arnulfo Tom  y está diseñado para facilitar tareas comunes relacionadas con la gestión de MongoDB en el contexto del servicio de monitoreo NMIS9 . El objetivo es proporcionar una herramienta que permita a los administradores realizar operaciones como listar bases de datos, respaldar colecciones, vaciar datos y verificar la integridad del sistema de manera eficiente. 
Información de Contacto 

    Correo Electrónico:  arnulfo.tom.tics@gmail.com 
    Versión del Script:  1.5
     

Condiciones de Uso 

Al utilizar este script, usted acepta los siguientes términos: 

    Licencia de Uso:  
        Este script se distribuye bajo una licencia de uso libre para propósitos educativos y de gestión de sistemas.
        Cualquier uso comercial o redistribución requiere autorización previa por escrito del autor.
         

    Garantías:  
        Este script se proporciona "tal cual", sin garantía de ningún tipo, ya sea explícita o implícita.
         

    Limitaciones de Responsabilidad:  
        El autor no será responsable por daños directos, indirectos, incidentales, especiales, ejemplares o consecuenciales que puedan surgir del uso de este script.
         

    Modificaciones:  
        Se permite la modificación del código siempre y cuando se mantenga intacto este encabezado de términos y licencias.
         

    Restricciones:  
        Este script está diseñado exclusivamente para ser utilizado con el servicio de monitoreo NMIS9  de FirstWave .
        No se garantiza su correcto funcionamiento en otras plataformas o servicios.
         
     

Pre-requisitos 

Antes de utilizar el script, asegúrese de cumplir con los siguientes requisitos: 

    Sistema Operativo:  
        El script está diseñado para ejecutarse en sistemas Linux.
         

    Dependencias:  
        MongoDB instalado y configurado correctamente.
        Herramientas de línea de comandos de MongoDB (mongo, mongodump, etc.).
         

    Permisos:  
        El usuario que ejecute el script debe tener permisos suficientes para acceder y modificar las bases de datos de MongoDB.
         

    Variables de Configuración:  
        Verifique que las variables en la sección de configuración del script estén correctamente establecidas:


MONGO_USER="opUserRW"
MONGO_PASS="op42flow42"
MONGO_HOST="localhost"
BACKUP_DIR="/tmp/bkp_mongo"
MONGOD_CONF="/etc/mongod.conf"

Configuración Inicial 

    Editar Variables de Configuración:  
        Abra el archivo del script en un editor de texto y modifique las variables según su entorno:

MONGO_USER="su_usuario"
MONGO_PASS="su_contraseña"
MONGO_HOST="su_host"
BACKUP_DIR="/ruta/a/respaldos"
MONGOD_CONF="/ruta/al/archivo/de/configuración"

Verificar Permisos:  

    Asegúrese de que el usuario que ejecuta el script tenga acceso a los archivos y directorios necesarios.
     

Hacer Ejecutable el Script:  

    Asigne permisos de ejecución al script:

chmod +x nombre_del_script.sh

Funcionalidades Principales 

El script incluye las siguientes funcionalidades: 

    Listar Bases de Datos y Tamaños:  
        Muestra todas las bases de datos disponibles junto con sus tamaños en MB.
         

    Listar Colecciones de una Base de Datos:  
        Enumera todas las colecciones dentro de una base de datos específica.
         

    Listar Tamaños de Colecciones:  
        Muestra el tamaño en MB de cada colección dentro de una base de datos.
         

    Respaldar Bases de Datos y Colecciones:  
        Realiza copias de seguridad completas o parciales (por base de datos o colección).
         

    Vaciar Bases de Datos y Colecciones:  
        Elimina todos los datos de una base de datos o colección específica.
         

    Verificar Integridad y Detalles de MongoDB:  
        Proporciona información detallada sobre el estado del servicio, configuración y permisos.
         
     

Instrucciones de Uso 

    Ejecutar el Script:  
        Ejecute el script desde la terminal:

./nombre_del_script.sh

    Seleccionar una Opción:  
        Siga las instrucciones en pantalla para seleccionar una opción del menú principal.
         

    Ejemplos Comunes:  

        Listar Bases de Datos:  
            Seleccione la opción 1 para ver todas las bases de datos y sus tamaños.
             

        Respaldar una Base de Datos:  
            Seleccione la opción 5, ingrese el nombre de la base de datos y siga las instrucciones.
             

        Vaciar una Colección:  
            Seleccione la opción 8, ingrese el nombre de la base de datos y la colección, y confirme la acción.
             
         

    Salir del Script:  
        Seleccione la opción 11 para salir del menú.
         
     

Soporte y Actualizaciones 

    Para actualizaciones o mantenimiento, comuníquese con el autor a través del correo electrónico proporcionado: arnulfo.tom.tics@gmail.com  .
    El autor no está obligado a proporcionar soporte técnico adicional, pero hará lo posible por responder consultas razonables.
     

Nota Final 

Este manual está diseñado para ayudar a los usuarios a comprender y utilizar el script de manera efectiva. Asegúrese de leer y comprender los términos de uso antes de implementar el script en su entorno. Al utilizar este software, usted acepta los términos establecidos anteriormente. 

Fin del Manual  
