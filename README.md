# ABAPUtils
Utilidades para mejorar la experiencia en el desarrollo de aplicaciones SAP ABAP.

**<ins>Nota</ins>** Para utilizar los objetos, los mismos deben subirse a SAP utilizando la herramienta abapGit.

A continuación, se listan los paquetes con las funcionalidades que aportan:

## ZPBF_XF_UTILS_TVARVC
Gestión moderna de valores constantes y variables para desarrollos (reemplazo de la clásica tabla estándar TVARVC). Aplicación SAP Fiori de tipo maestro-detalle desarrollada bajo el marco de trabajo ABAP RAP (RESTful Application Programming Model) y el protocolo OData V4.

Proporciona un entorno seguro, transaccional y multi-idioma con soporte de borradores (Draft), garantizando un diseño normalizado (3NF) y un comportamiento Clean Core.

La solución está compuesta por:
- **ZCL_XC_RICEF_CONSTANTS**: API de consumo público para otros programas ABAP. Implementa un patrón de caché estático (Lazy Loading) para evitar accesos redundantes a la base de datos. Expone los métodos GET_PARAM (recupera un valor único) y GET_RANGE (devuelve una tabla interna formateada como rango estándar de ABAP, lista para sentencias IN).
- **ZCL_XC_RICEFH_BP**: Behavior Pool que centraliza la lógica de negocio transaccional. Implementa determinaciones de auto-formateo, auto-numeración de secuencias, smart defaults (pre-carga de signos/opciones según el tipo de variable) y validaciones estrictas (anti-duplicados y consistencia de llaves).
- **Modelo de Datos (VDM)**: Jerarquía de Vistas CDS (ZI_XC_RICEFH, ZI_XC_RICEFI, ZI_XC_RICEFT) que soportan la cabecera, los items y los textos dependientes de idioma. Incluye vistas de ayuda de búsqueda (VH) para exponer los dominios de tipo, signo y opción.
- **Persistencia**: Tablas de clase de entrega C (Customizing) separadas lógicamente (ZXC_TBL_RICEFH, ZXC_TBL_RICEFI, ZXC_TBL_RICEFT), junto con sus respectivas tablas de Draft administradas por el framework RAP.
- **Integración CTS (Transportes)**: Intercepta la acción de transporte del usuario, resuelve la orden de Customizing o Workbench correspondiente y empaqueta las llaves utilizando un comodín genérico (*). Esto fuerza al programa R3trans de SAP a realizar un reemplazo total (Full Replace) en los ambientes destino, sincronizando automáticamente inserciones, modificaciones y borrados físicos sin necesidad de tablas shadow.
- **Frontend SAP Fiori**: Aplicación BSP generada con Fiori Elements OData V4, utilizando Flexible Column Layout (FCL) y Flexible Programming Model (FPM) para edición en línea (Inline Editing) e integración nativa con el motor de idiomas.


**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados bajo las directrices de ABAP RAP y Clean Core. Para acceder a la interfaz de usuario, la aplicación web (BSP) debe ser configurada en el SAP Fiori Launchpad On-Premise a través del Content Manager (Catálogo, Tile y Target Mapping apuntando al objeto semántico de la aplicación). La lectura de constantes por parte de los desarrolladores debe realizarse exclusivamente a través de la clase ZCL_XC_RICEF_CONSTANTS.


## ZPBF_XF_UTILS_FILEMAP
Mapeo del contenido de un archivo de texto a estructuras ABAP. Recibe el contenido ya leído (como tabla de líneas) y lo vuelca en la estructura destino, aplicando validación y transformación por campo. Modernización del framework Z_FILE_READER_HANDLER, separando la lectura del archivo (responsabilidad de ZPBF_XF_UTILS_FILE) del mapeo del contenido (este paquete): la frontera entre ambas capas es el contenido en memoria, por lo que el mapeo es independiente del origen del archivo (servidor de aplicaciones, carga web, BTP, etc.).

La solución sigue un patrón de pipeline con estrategias inyectables:

- **ZCL_XC_FILE_CONTENT_READER**: Orquestador. Recibe el contenido (tabla de líneas) y la configuración por constructor, y mediante PROCESS vuelca la cabecera y los registros en las estructuras destino, descartando las líneas inválidas y acumulando los mensajes del proceso.
- **ZIF_XC_LINE_MAPPER / ZCL_XC_LINE_MAPPER**: Estrategia de mapeo de una línea a una estructura. El mapper es único; lo que varía (cómo se parte la línea) se delega a un extractor inyectable.
- **ZIF_XC_VALUE_EXTRACTOR**: Contrato del extractor de valores de una línea. Implementaciones:
  - **ZCL_XC_FIXED_EXTRACTOR**: Extracción por posición fija (según la longitud de cada campo).
  - **ZCL_XC_SEP_EXTRACTOR**: Extracción por separador de campos.
- **ZIF_XC_FIELD_VALIDATOR**: Contrato de validación de un campo. Doble modo: rechazo recuperable (descarta la línea) o terminal (lanza excepción).
- **ZIF_XC_VALUE_TRANSFORMER**: Contrato de transformación del valor de un campo (recibe el nombre del campo y el valor crudo, devuelve el valor transformado).
- **ZCX_XC_FILE_MAPPER**: Excepción tipada (CX_STATIC_CHECK) que reporta campo inexistente, dato no estructurado, error de validación o transformación, y discrepancia entre la cantidad de valores y de campos.

Validación y transformación se inyectan en el mapper y se aplican únicamente a los registros, no a la cabecera. Un mismo validador/transformador atiende todos los campos de la estructura, discriminando por nombre de campo.

**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados en ABAP Cloud (Released APIs únicamente), por lo que son aptos para entornos S/4HANA con restricción Clean Core. La lectura del archivo se resuelve por separado (ver ZPBF_XF_UTILS_FILE).

**<ins>Ejemplo de uso:</ins>** La clase ZCL_XC_FILE_MAPPER_DEMO (ejecutable vía IF_OO_ADT_CLASSRUN) arma contenido de ejemplo en memoria y lo procesa con ambos extractores (posición fija y separador), incluyendo cabecera, registros, una validación que descarta una línea inválida y una transformación de campo.

## ZPBF_XF_UTILS_FILE
Operaciones sobre archivos del application server (escritura, append, listado y validación de rutas), con codepage configurable y soporte de escritura concurrente mediante bloqueo.

La solución está compuesta por:

- **ZIF_XC_FILE_UTILS**: Interfase pública que define el contrato (métodos LIST, WRITE_FILE, APPEND_STRING, APPEND_FILE, DEFENSIVE_CHECK, CALCULATE_HASH y VERIFY_HASH). El codepage, el separador de línea y la vía lógica del ámbito seguro se configuran en el constructor de la implementación.
- **ZCL_XC_FILE_UTILS**: Implementación concreta (FINAL). Métodos de instancia.
- **ZCX_XC_FILE_UTILS**: Excepción tipada (CX_STATIC_CHECK) que reporta toda falla (apertura, lectura, escritura, bloqueo, ámbito o listado), preservando la causa original.
- **ZXC_S_FILE_INFO / ZXC_T_FILE_INFO**: Estructura y tabla con la metadata devuelta por LIST.
- **ZXC_FILE_LOCK / EZXC_FILE_LOCK**: Tabla y objeto de bloqueo que dan soporte a la escritura concurrente.

Métodos de la interfase:

- **LIST**: Lista los archivos de un directorio del AS, devolviendo su metadata (nombre, tamaño, propietario, fecha de modificación, etc.). Los no usables (directorios, tamaño 0) se incluyen marcados.
- **WRITE_FILE**: Escribe un string en el archivo destino, sobrescribiendo su contenido. El codepage se toma de la configuración de la instancia.
- **APPEND_STRING**: Agrega un string al final del archivo destino. Admite escritura concurrente protegida por bloqueo.
- **APPEND_FILE**: Agrega el contenido de un archivo de entrada al final de otro de salida, con opción de borrar el origen y de escritura concurrente.
- **DEFENSIVE_CHECK**: Verifica que las rutas indicadas se encuentren dentro del ámbito seguro configurado (vía logical filename). Lanza excepción si alguna está fuera.
- **CALCULATE_HASH**: Calcula el hash de un contenido binario (xstring) y lo devuelve en formato hexadecimal. El algoritmo es configurable (por defecto SHA-256).
- **VERIFY_HASH**: Calcula el hash de un contenido y lo compara contra un hash esperado, devolviendo si coinciden (comparación no sensible a mayúsculas/minúsculas).

**<ins>Nota:</ins>** Clase ABAP Standard (On-Premise): utiliza OPEN DATASET y listado de directorio del AS, por lo que no es ABAP Cloud-compliant. Diseñada para S/4HANA On-Premise.

## ZPBF_XF_UTILS_SERIAL
Serialización de objetos y persistencia de su estado en base de datos. El paquete resuelve dos necesidades complementarias: convertir una instancia a una representación binaria (y viceversa), y guardar/recuperar esas instancias asociadas a la ejecución de un proceso.

### Serialización
Permite serializar (y des-serializar) objetos que implementen la interfase IF_SERIALIZABLE_OBJECT. Resulta útil cuando se necesita convertir el estado de una instancia a una forma transmisible o almacenable.

- **ZIF_XC_OBJECT_SERIALIZER**: Interfase pública que define el contrato de serialización (métodos SERIALIZE y DESERIALIZE).
- **ZCL_XC_OBJECT_SERIALIZER**: Implementación concreta. Recibe en su constructor el parámetro COMPRESS (booleano, por defecto activo), que indica si el payload debe comprimirse con GZIP.
- **ZCX_XC_SERIALIZATION**: Excepción tipada (CX_STATIC_CHECK) que reporta fallas en serialización, des-serialización, compresión o descompresión, preservando la excepción original como causa.

### Persistencia
Permite guardar instancias serializadas en base de datos y recuperarlas posteriormente, organizadas en tres niveles: el proceso (REPID), la corrida o ejecución concreta (RUN_ID) y el objeto individual dentro de esa corrida (OBJECT_KEY). Así es posible, por ejemplo, ejecutar un mismo proceso varias veces en el día y recuperar luego la familia completa de objetos de una corrida en particular.

- **ZIF_XC_OBJECT_REPOSITORY**: Interfase pública del repositorio. Expone SAVE (persiste un objeto y devuelve su clave), LOAD (recupera un objeto puntual), LOAD_RUN (recupera todos los objetos de una corrida), LIST_RUNS (lista las corridas de un proceso con su cantidad de objetos), DELETE y DELETE_RUN.
- **ZCL_XC_OBJECT_REPOSITORY**: Implementación concreta. Recibe el serializador en su constructor (composición), por lo que la estrategia de serialización es configurable e intercambiable. No ejecuta COMMIT WORK: la transacción queda bajo control del llamador.
- **ZXC_OBJ_STORE**: Tabla transparente donde se persisten los objetos, con su clase, fecha y usuario de creación.

El RUN_ID que agrupa una corrida lo genera el llamador (una vez al iniciar la ejecución) y lo reutiliza en cada SAVE; el OBJECT_KEY de cada objeto lo genera el repositorio automáticamente.

**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados en ABAP Cloud (Released APIs únicamente), por lo que son aptos para entornos S/4HANA con restricción Clean Core.

## ZPBF_XF_UTILS_LOG
Wrapper orientado a objetos sobre el Application Log de SAP (la infraestructura detrás de SLG0/SLG1), que simplifica el registro de mensajes, textos libres y excepciones en un log de aplicación. 

La solución está compuesta por:

- **ZIF_XC_APP_LOG**: Interfase pública que define el contrato del log. El objeto, subobjeto e identificador externo se configuran en el constructor de la implementación.
- **ZCL_XC_APP_LOG**: Implementación concreta (FINAL). Métodos de instancia. No ejecuta COMMIT WORK: la transacción la controla el llamador.
- **ZCX_XC_APP_LOG**: Excepción tipada (CX_STATIC_CHECK) que reporta toda falla del log, preservando la causa original.

Métodos principales de la interfase:

- **ADD_MESSAGE**: Agrega un mensaje por clase y número, con una severidad explícita.
- **ADD_ERROR / ADD_WARNING / ADD_INFO / ADD_SUCCESS**: Atajos que agregan un mensaje con la severidad correspondiente.
- **ADD_FROM_SY**: Agrega un mensaje a partir de las variables de sistema (SY-MSG*).
- **ADD_FREE_TEXT**: Agrega un texto libre, sin necesidad de clase de mensajes.
- **ADD_EXCEPTION**: Registra una excepción en el log, incluyendo su cadena de causas.
- **ADD_FROM_BAPIRET**: Agrega los mensajes contenidos en una tabla BAPIRET2.
- **SAVE**: Persiste el log en base de datos (visible luego en SLG1).
- **GET_MESSAGES**: Devuelve los items del log en memoria.
- **GET_HANDLE**: Devuelve el handle del log.

**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados en ABAP Cloud (Released APIs únicamente), por lo que son aptos para entornos S/4HANA con restricción Clean Core. La visualización de los logs se realiza mediante la transacción SLG1.

A continuación, se adjunta el documento técnico con los detalles de diseño y un ejemplo de implementación: [Log OO API (Implementación Propia).docx]

## ZPBF_XF_UTILS_STRING
Utilidades para el trabajo con cadenas de caracteres: conversión entre estructuras/tablas internas y strings, y mapeo configurable de estructuras a un formato de salida de ancho fijo.

### Conversión estructura ↔ string
Conversión entre estructuras/tablas internas y cadenas de caracteres.

La solución está compuesta por:

- **ZIF_XC_STRING_UTILS**: Interfase pública que define el contrato.
- **ZCL_XC_STRING_UTILS**: Implementación concreta (FINAL). Métodos de instancia.
- **ZCX_XC_STRING_UTILS**: Excepción tipada (CX_STATIC_CHECK) que reporta fallas de parsing (estructura inexistente, nombre que no es estructura, o cantidad de columnas que no coincide).

Métodos de la interfase:

- **STRUCT_TO_STRING**: Convierte una estructura (incluyendo estructuras y tablas internas anidadas) en una cadena de caracteres, recorriéndola recursivamente. Permite indicar el separador de línea, omitir componentes vacíos y excluir campos específicos.
- **STRING_TO_ITAB**: Construye dinámicamente una tabla interna, tipada según una estructura del diccionario, a partir de una cadena delimitada. El separador de campo y de registro son configurables, y puede descartar opcionalmente la primera fila (encabezado).
- **DETERMINE_LINE_SEP**: Determina el separador de línea utilizado en un texto (CR_LF, CR o LF).

### Mapeo de estructura a string (ancho fijo)
Mapeo configurable de una estructura de datos a un string formateado de ancho fijo, listo para que otra capa lo escriba como archivo. Modernización de la antigua ZCL_STRUCT_MAPPER_TO_OUTFILE: la responsabilidad se acota exclusivamente al mapeo (no escribe archivos), se elimina la dependencia del sistema operativo (CALL 'SYSTEM') y la invocación dinámica de métodos, y se sustituye la herencia por composición.

El formato de salida se define en la tabla de parametrización **ZXC_STRUCT_MAP**, donde cada fila describe un campo: a qué registro (línea) y posición pertenece, qué campo de la estructura mapea, su longitud (ancho fijo), su alineación (IZQ/DER) y, opcionalmente, una transformación a aplicar.

La solución sigue un patrón Composite, donde un documento se compone de secciones independientes:

- **ZIF_XC_FILE_SECTION**: Contrato de una sección. Define RENDER, que devuelve el contenido de la sección como string.
- **ZCL_XC_FILE_DOCUMENT**: Compositor. Agrupa secciones ordenadas (ADD_SECTION, fluido) y las concatena en el string final (RENDER).
- **ZCL_XC_STRUCT_MAPPER**: Sección que mapea una estructura según la configuración. Aplica ancho fijo, alineación, corte de control por registro y transformaciones.
- **ZCL_XC_STRUCT_TABLE_MAPPER**: Sección que mapea una tabla interna, generando el grupo de líneas correspondiente por cada fila (reutiliza internamente ZCL_XC_STRUCT_MAPPER).
- **ZCL_XC_TEXT_SECTION**: Sección de texto fijo (encabezados/pies de archivo), que no mapea datos.

Transformaciones de campo (inyectables):

- **ZIF_XC_FIELD_TRANSFORMER**: Contrato de un transformador de valor (TRANSFORM: valor → valor). Se registra en el mapper con ADD_TRANSFORMER (fluido), asociado a la clave indicada en la columna ACCIÓN de la configuración. Permite, por ejemplo, traducir un código interno de SAP al código que espera el sistema externo. Si la clave referida en la configuración no está registrada, o el transformador no puede resolver el valor, se lanza una excepción (sin conversiones silenciosas).

Manejo de errores:

- **ZCX_XC_STRUCT_MAPPER**: Excepción tipada (CX_STATIC_CHECK) que reporta campo inexistente, dato no estructurado, configuración ausente, transformador no registrado o error en una transformación.

**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados en ABAP Cloud (Released APIs únicamente), por lo que son aptos para entornos S/4HANA con restricción Clean Core.

**<ins>Ejemplo de uso:</ins>** La clase ZCL_XC_STRUCT_MAPPER_DEMO (ejecutable vía IF_OO_ADT_CLASSRUN) construye un documento de ejemplo —encabezado de archivo, cabecera de factura y posiciones, con transformación de sociedad y de concepto— y renderiza el string resultante en la consola de ADT, como referencia de uso end-to-end.

## ZPBF_XF_UTILS_DATA
Utilidades para trabajar con tipos de datos dinámicos a partir de estructuras del diccionario.

La solución está compuesta por:

- **ZIF_XC_DATA_UTILS**: Interfase pública que define el contrato.
- **ZCL_XC_DATA_UTILS**: Implementación concreta (FINAL). Métodos de instancia.
- **ZCX_XC_DATA_UTILS**: Excepción tipada (CX_STATIC_CHECK) que reporta si la estructura no existe o si el nombre no corresponde a una estructura.

Métodos de la interfase:

- **STRUCT_BY_FIELD_NAMES**: Dado el nombre de una estructura del diccionario, devuelve una referencia a una estructura dinámica donde cada campo es de tipo CHAR con la longitud de su propio nombre. Útil como mapa de nombres de campo (por ejemplo, para asignación dinámica de componentes o para mapear contra claves de un JSON).
- **ITAB_BY_STRUCT_NAME**: Dado el nombre de una estructura del diccionario, devuelve una referencia a una tabla interna cuyo tipo de línea es esa estructura, preservando los tipos reales de cada campo.

**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados en ABAP Cloud (Released APIs únicamente), por lo que son aptos para entornos S/4HANA con restricción Clean Core.

## ZPBF_XF_UTILS_HTML
Generación de contenido HTML mediante un mini-DOM de clases (patrón Composite): cada elemento es un nodo que puede contener otros nodos y sabe renderizarse a sí mismo y a sus hijos. 

La jerarquía se apoya en un contrato común y una clase base:

- **ZIF_XC_HTML_ELEMENT**: Interfase que define el contrato de todo nodo HTML (to_html, add_child, add_attribute, set_value, get_value, has_child). Los métodos add_child y add_attribute devuelven el propio nodo, permitiendo encadenar llamadas (fluent interface).
- **ZCL_XC_HTML_ELEMENT**: Clase base (no final) que implementa la interfase y resuelve el renderizado recursivo de atributos e hijos. El resto de los elementos heredan de ella.

Elementos especializados:

- **ZCL_XC_HTML_DOCUMENT**: Documento completo (html), con sus nodos head y body. El título de la página se coloca correctamente dentro de un elemento title.
- **ZCL_XC_HTML_TITLE / ZCL_XC_HTML_STYLE / ZCL_XC_HTML_PARAGRAPH**: Título de página, bloque de estilos CSS y párrafo. El párrafo recibe el texto ya resuelto (no lee textos maestros).
- **ZCL_XC_HTML_LINE_BREAK**: Salto de línea (br), elemento void.
- **ZCL_XC_HTML_IMAGE**: Imagen (img). Admite imagen por URL o embebida como data-URI base64 mediante el método EMBED_BASE64, que recibe el binario y el tipo MIME. Métodos SET_WIDTH y SET_HEIGHT para las dimensiones.
- **ZCL_XC_HTML_TABLE**: Tabla (table). Se llena a partir de una tabla interna (SET_TABLE_DATA) o de una estructura (SET_STRUCT_DATA), determinando columnas y etiquetas por RTTI. Permite indicar los campos visibles y etiquetas de columna configurables (con fallback al nombre técnico del campo). Las tablas internas anidadas se aplanan a CSV.
- **ZCL_XC_HTML_TABLE_ROW / ZCL_XC_HTML_TABLE_CELL / ZCL_XC_HTML_TABLE_HEADER_CELL**: Fila (tr), celda (td) y celda de encabezado (th).

Manejo de errores:

- **ZCX_XC_HTML**: Excepción tipada (CX_STATIC_CHECK) que reporta si el dato proporcionado a la tabla no es una tabla interna o una estructura.

Ejemplo de uso:

- **ZCL_XC_HTML_DEMO**: Es ejecutable vía IF_OO_ADT_CLASSRUN, y construye un documento completo que ejercita todos los elementos de la librería —documento, estilos, párrafo, las dos formas de llenado de tabla, imagen por URL e imagen embebida en base64— y renderiza el HTML resultante en la consola de ADT. Sirve como referencia de uso end-to-end.

**<ins>Nota:</ins>** Los objetos de este paquete están desarrollados en ABAP Cloud (Released APIs únicamente), por lo que son aptos para entornos S/4HANA con restricción Clean Core. La lectura de textos maestros (SO10) y de imágenes del MIME repository quedan fuera de la librería: el párrafo recibe el texto resuelto y la imagen recibe el binario, ambos provistos por el llamador.


