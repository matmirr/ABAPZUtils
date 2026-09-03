interface zif_xc_html_element
  public.

  "! <p class="shorttext synchronized">Tabla de nodos HTML</p>
  types tt_element type standard table of ref to zif_xc_html_element with empty key.

  "! <p class="shorttext synchronized">Par nombre/valor para atributos HTML</p>
  types: begin of ts_attribute,
           name  type string,
           value type string,
         end of ts_attribute.
  types tt_attribute type standard table of ts_attribute with empty key.

  "! <p class="shorttext synchronized">Renderiza el nodo (y sus hijos) a HTML</p>
  "! @parameter result | Representación HTML del nodo.
  methods to_html
    returning value(result) type string.

  "! <p class="shorttext synchronized">Agrega un nodo hijo</p>
  "! @parameter child  | Nodo hijo a agregar.
  "! @parameter result | El propio nodo (para encadenar llamadas).
  methods add_child
    importing !child        type ref to zif_xc_html_element
    returning value(result) type ref to zif_xc_html_element.

  "! <p class="shorttext synchronized">Agrega un atributo al nodo</p>
  "! @parameter name   | Nombre del atributo.
  "! @parameter value  | Valor del atributo.
  "! @parameter result | El propio nodo (para encadenar llamadas).
  methods add_attribute
    importing !name         type string
              !value        type string
    returning value(result) type ref to zif_xc_html_element.

  "! <p class="shorttext synchronized">Indica si el nodo tiene hijos</p>
  "! @parameter result | abap_true si tiene al menos un hijo.
  methods has_child
    returning value(result) type abap_bool.

  "! <p class="shorttext synchronized">Define el contenido textual del nodo</p>
  "! @parameter value | Texto del nodo.
  methods set_value
    importing !value type string.

  "! <p class="shorttext synchronized">Devuelve el contenido textual del nodo</p>
  "! @parameter result | Texto del nodo.
  methods get_value
    returning value(result) type string.

endinterface.
