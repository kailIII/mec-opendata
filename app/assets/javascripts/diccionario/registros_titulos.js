function contenido_diccionario(url_anho_cod_geo) {
    var diccionario = [
        {
            nombre: 'AÑO',
            descripcion: 'Se refiere al año de registro del t&iacute;tulo',
            tipo: 'xsd:gYear',
            restricciones: 'Sólo permite la carga de datos del año de registro del t&iacute;tulo',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '2012'
        }, {
            nombre: 'MES',
            descripcion: 'Se refiere al mes de registro del t&iacute;tulo',
            tipo: 'xsd:positiveInteger',
            restricciones: 'Sólo permite la carga de datos del mes del registro del título',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '1'
        }, {
            nombre: 'DOCUMENTO',
            descripcion: 'Se refiere al número de documento de identidad de la persona',
            tipo: 'xsd:string',
            restricciones: 'No m&aacute;s de 10 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '123456'
        }, {
            nombre: 'NOMBRE_COMPLETO',
            descripcion: 'Se refiere al o los nombres y al o los apellidos de la persona cuyo título fue registrado',
            tipo: 'xsd:string',
            restricciones: 'No más de 100 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: 'Esteban Benítez'
        }, {
            nombre: 'CARRERA_ID',
            descripcion: 'Corresponde al código asignado a la carrera',
            tipo: 'xsd:positiveInteger',
            restricciones: 'Mayor a cero',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '1'
        }, {
            nombre: 'CARRERA',
            descripcion: 'Oferta educativa implementada en la Institución conforme a normativas vigentes',
            tipo: 'xsd:string',
            restricciones: 'No más de 150 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: 'Ciencias de la Educación'
        }, {
            nombre: 'TITULO_ID',
            descripcion: 'Corresponde al código asignado a la t&iacute;tulo',
            tipo: 'xsd:positiveInteger',
            restricciones: 'Mayor a cero',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '1'
        }, {
            nombre: 'TITULO',
            descripcion: 'Corresponde a la certificación documental expedida por una institución educativa del nivel superior que avala la formación de la persona en  una profesión o conocimientos académicos de una disciplina',
            tipo: 'xsd:string',
            restricciones: 'No más de 150 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: 'LICENCIADO'
        }, {
            nombre: 'NUMERO_RESOLUCION',
            descripcion: 'Número del acto administrativo por el cual se autoriza el Registro del Título',
            tipo: 'xsd:string',
            restricciones: 'No más de 5 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '12345'
        }, {
            nombre: 'FECHA_RESOLUCION',
            descripcion: 'Fecha de  la Resolución del Registro del Título',
            tipo: 'xsd:date',
            restricciones: '',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '2014-08-01'
        }, {
            nombre: 'TIPO_INSTITUCION_ID',
            descripcion: 'Corresponde al código asignado al tipo de institución',
            tipo: 'xsd:positiveInteger',
            restricciones: 'Mayor a cero',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '1'
        }, {
            nombre: 'TIPO_INSTITUCION',
            descripcion: 'Se refiere al tipo de institución',
            tipo: 'xsd:string',
            restricciones: 'No más de 150 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: 'UNIVERSIDAD, INSTITUCION SUPERIOR'
        }, {
            nombre: 'INSTITUCION_ID',
            descripcion: 'Identifica a la institución como una entidad y organización independiente que funciona dentro de un establecimiento escolar. Una institución educativa puede poseer diferentes locales escolares ubicados en un mismo o en diferentes departamentos geográficos. El código está compuesto por un número secuencial',
            tipo: 'xsd:positiveInteger',
            restricciones: 'Mayor a cero',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '1247'
        }, {
            nombre: 'INSTITUCION',
            descripcion: 'Corresponde a la descripción del nombre de la institución correspondiente al código',
            tipo: 'xsd:string',
            restricciones: 'No más de 150 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: '1000031  UNIVERSIDAD METROPOLITANA'
        }, {
            nombre: 'GOBIERNO_ACTUAL',
            descripcion: 'Indica si los Títulos fueron registro bajo el Gobierno actual',
            tipo: 'xsd:string',
            restricciones: 'No más de 2 caracteres',
            referencia: {
                texto: '',
                enlace: ''
            },
            ejemplo: 'SI'
        }
    ];
    return diccionario;
}