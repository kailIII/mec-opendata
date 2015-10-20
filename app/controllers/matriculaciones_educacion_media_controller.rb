class MatriculacionesEducacionMediaController < ApplicationController
  
  def index
    @matriculaciones_educacion_media = MatriculacionEducacionMedia.orden_dep_dis.paginate :per_page => 15, :page => params[:page]
    respond_to do |f|

      f.html {render :layout => 'application'}

    end
  end
  
  def diccionario
    
    require 'json'
    file = File.read("#{Rails.root}/app/assets/javascripts/diccionario/matriculaciones_educacion_media.json")
    diccionario = JSON.parse(file)
    @diccionario_matriculaciones_educacion_media = clean_json(diccionario)

    if params[:format] == 'json'
      
      generate_json_table_schema(@diccionario_matriculaciones_educacion_media)

    elsif params[:format] == 'pdf'
      
      send_data(generate_pdf(@diccionario_matriculaciones_educacion_media, params[:nombre]), :filename => "diccionario_matriculaciones_educacion_media.pdf", :type => "application/pdf")

    end
    
  end

  def lista

    cond = []
    args = []
    estados = []

    if params[:form_buscar_matriculaciones_educacion_media] &&
        params[:form_buscar_matriculaciones_educacion_media][:anio].present?

      cond << "anio = ?"
      args << params[:form_buscar_matriculaciones_educacion_media][:anio]

    end

    if params[:form_buscar_matriculaciones_educacion_media_nombre_departamento].present?

      cond << "nombre_departamento ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_matriculaciones_educacion_media_nombre_departamento])}%"

    end

    if params[:form_buscar_matriculaciones_educacion_media_nombre_distrito].present?

      cond << "nombre_distrito ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_matriculaciones_educacion_media_nombre_distrito])}%"

    end

    if params[:form_buscar_matriculaciones_educacion_media_nombre_barrio_localidad].present?

      cond << "nombre_barrio_localidad ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_matriculaciones_educacion_media_nombre_barrio_localidad])}%"

    end
    
    if params[:form_buscar_matriculaciones_educacion_media][:nombre_zona].present?

      cond << "nombre_zona = ?"
      args << "#{params[:form_buscar_matriculaciones_educacion_media][:nombre_zona]}"

    end

    if params[:form_buscar_matriculaciones_educacion_media_codigo_establecimiento].present?

      cond << "codigo_establecimiento ilike ?"
      args << "%#{params[:form_buscar_matriculaciones_educacion_media_codigo_establecimiento]}%"

    end

    if params[:form_buscar_matriculaciones_educacion_media_codigo_institucion].present?

      cond << "codigo_institucion = ?"
      args << params[:form_buscar_matriculaciones_educacion_media_codigo_institucion]

    end

    if params[:form_buscar_matriculaciones_educacion_media_nombre_institucion].present?

      cond << "nombre_institucion ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_matriculaciones_educacion_media_nombre_institucion])}%"

    end

    if params[:form_buscar_matriculaciones_educacion_media_sector_o_tipo_gestion].present?

      cond << "sector_o_tipo_gestion ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_matriculaciones_educacion_media_sector_o_tipo_gestion])}%"

    end

    if params[:form_buscar_matriculaciones_educacion_media_matricula_cientifico].present?

      cond << "matricula_cientifico #{params[:form_buscar_matriculaciones_educacion_media_matricula_cientifico_operador]} ?"
      args << params[:form_buscar_matriculaciones_educacion_media_matricula_cientifico]

    end

    if params[:form_buscar_matriculaciones_educacion_media_matricula_tecnico].present?

      cond << "matricula_tecnico #{params[:form_buscar_matriculaciones_educacion_media_matricula_tecnico_operador]} ?"
      args << params[:form_buscar_matriculaciones_educacion_media_matricula_tecnico]

    end

    if params[:form_buscar_matriculaciones_educacion_media_matricula_media_abierta].present?

      cond << "matricula_media_abierta #{params[:form_buscar_matriculaciones_educacion_media_matricula_media_abierta_operador]} ?"
      args << params[:form_buscar_matriculaciones_educacion_media_matricula_media_abierta]

    end

    if params[:form_buscar_matriculaciones_educacion_media_matricula_formacion_profesional_media].present?

      cond << "matricula_formacion_profesional_media #{params[:form_buscar_matriculaciones_educacion_media_matricula_formacion_profesional_media_operador]} ?"
      args << params[:form_buscar_matriculaciones_educacion_media_matricula_formacion_profesional_media]

    end

    cond = cond.join(" and ").lines.to_a + args if cond.size > 0
    
    if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
      @matriculaciones_educacion_media = MatriculacionEducacionMedia.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond).paginate(page: params[:page], per_page: 15)
    else
      @matriculaciones_educacion_media = MatriculacionEducacionMedia.orden_dep_dis.where(cond).paginate(page: params[:page], per_page: 15)
    end

    @total_registros = MatriculacionEducacionMedia.count 

    if params[:format] == 'csv'

      require 'csv'
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        matriculaciones_educacion_media_csv = MatriculacionEducacionMedia.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        matriculaciones_educacion_media_csv = MatriculacionEducacionMedia.orden_dep_dis.where(cond)
      end

      csv = CSV.generate do |csv|
        # header row
        csv << ["anio", "codigo_departamento", "nombre_departamento",
          "codigo_distrito", "nombre_distrito", "codigo_barrio_localidad",
          "nombre_barrio_localidad", "codigo_zona", "nombre_zona",
          "codigo_establecimiento", "codigo_institucion", "nombre_institucion",
          "sector_o_tipo_gestion", "matricula_cientifico", "matricula_tecnico", 
          "matricula_media_abierta", "matricula_formacion_profesional_media", "anio_cod_geo" ]
 
        # data rows
        matriculaciones_educacion_media_csv.each do |e|
          csv << [e.anio, e.codigo_departamento, e.nombre_departamento,
            e.codigo_distrito, e.nombre_distrito, e.codigo_barrio_localidad,
            e.nombre_barrio_localidad, e.codigo_zona, e.nombre_zona,
            e.codigo_establecimiento, e.codigo_institucion, e.nombre_institucion,
            e.sector_o_tipo_gestion, e.matricula_cientifico, e.matricula_tecnico,
            e.matricula_media_abierta, e.matricula_formacion_profesional_media, e.anio_cod_geo ]
        end

      end
    
      send_data(csv, :type => 'text/csv', :filename => "matriculaciones_educacion_media_#{Time.now.strftime('%Y%m%d')}.csv")

    elsif params[:format] == 'xlsx'
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        @matriculaciones_educacion_media = MatriculacionEducacionMedia.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        @matriculaciones_educacion_media = MatriculacionEducacionMedia.orden_dep_dis.where(cond)
      end

      p = Axlsx::Package.new
      
      p.workbook.add_worksheet(:name => "Matriculaciones EM") do |sheet|
          
        sheet.add_row [:anio, :codigo_departamento, :nombre_departamento, 
          :codigo_distrito, :nombre_distrito, :codigo_barrio_localidad,
          :nombre_barrio_localidad, :codigo_zona, :nombre_zona, 
          :codigo_establecimiento, :codigo_institucion, :nombre_institucion,
          :sector_o_tipo_gestion, :matricula_cientifico, :matricula_tecnico,
          :matricula_media_abierta, :matricula_formacion_profesional_media, :anio_cod_geo]

        @matriculaciones_educacion_media.each do |m|
            
          sheet.add_row [m.anio, m.codigo_departamento, m.nombre_departamento, 
            m.codigo_distrito, m.nombre_distrito, m.codigo_barrio_localidad,
            m.nombre_barrio_localidad, m.codigo_zona, m.nombre_zona, 
            m.codigo_establecimiento, m.codigo_institucion, m.nombre_institucion,
            m.sector_o_tipo_gestion, m.matricula_cientifico, m.matricula_tecnico,
            m.matricula_media_abierta, m.matricula_formacion_profesional_media, m.anio_cod_geo]

        end

      end
      
      p.use_shared_strings = true
      
      send_data p.to_stream.read, filename: "matriculaciones_educacion_media_#{Time.now.strftime('%d%m%Y__%H%M')}.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet", disposition: 'attachment'

    elsif params[:format] == 'pdf'

      report = ThinReports::Report.new layout: File.join(Rails.root, 'app',
        'reports', 'matriculaciones_educacion_media.tlf')
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        matriculaciones_educacion_media = MatriculacionEducacionMedia.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        matriculaciones_educacion_media = MatriculacionEducacionMedia.orden_dep_dis.where(cond)
      end
    
      report.start_new_page do |page|
      
        page.item(:fecha_hora).value("Fecha y Hora: #{Time.now.strftime('%d/%m/%Y - %H:%M')}")
    
      end

      matriculaciones_educacion_media.each do |e|
      
        report.list(:matriculaciones_educacion_media).add_row do |row|

          row.values  anio: e.anio,
            codigo_departamento: e.codigo_departamento.to_s,        
            nombre_departamento: e.nombre_departamento.to_s,       
            codigo_distrito: e.codigo_distrito.to_s,       
            nombre_distrito: e.nombre_distrito.to_s,
            codigo_barrio_localidad: e.codigo_barrio_localidad,
            nombre_barrio_localidad: e.nombre_barrio_localidad,       
            codigo_zona: e.codigo_zona.to_s,       
            nombre_zona: e.nombre_zona.to_s,
            codigo_establecimiento: e.codigo_establecimiento.to_s,
            codigo_institucion: e.codigo_institucion.to_s,
            nombre_institucion: e.nombre_institucion.to_s,
            sector_o_tipo_gestion: e.sector_o_tipo_gestion.to_s,
            matricula_cientifico: e.matricula_cientifico.to_s,
            matricula_tecnico: e.matricula_tecnico.to_s,
            matricula_media_abierta: e.matricula_media_abierta.to_s,
            matricula_formacion_profesional_media: e.matricula_formacion_profesional_media.to_s      

        end

      end


      send_data report.generate, filename: "matriculaciones_educacion_media_#{Time.now.strftime('%d%m%Y__%H%M')}.pdf", 
        type: 'application/pdf', 
        disposition: 'attachment'

    elsif params[:format] == 'md5_csv'
      
      filename = "matriculaciones_educacion_media_" + params[:form_buscar_matriculaciones_educacion_media][:anio]
      path_file = "#{Rails.root}/public/data/" + filename + ".csv"
      send_data(generate_md5(path_file), :filename => filename+".md5", :type => "application/txt")


    else
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        @matriculaciones_educacion_media_todos = MatriculacionEducacionMedia.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        @matriculaciones_educacion_media_todos = MatriculacionEducacionMedia.orden_dep_dis.where(cond)
      end
      
      respond_to do |f|

        f.js
        f.json {render :json => @matriculaciones_educacion_media_todos }

      end 

    end

  end
end
