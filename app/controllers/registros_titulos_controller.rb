class RegistrosTitulosController < ApplicationController
  
  def index
    
    @registros_titulos = RegistroTitulo.orden_anio_mes.paginate :per_page => 15, :page => params[:page]
    
    respond_to do |f|

      f.html {render :layout => 'layouts/application_wide'}
    
    end

  end

  def lista

    cond = []
    args = []
    estados = []

    if params[:form_buscar_registros_titulos] && params[:form_buscar_registros_titulos][:anio].present?

      cond << "anio = ?"
      args << params[:form_buscar_registros_titulos][:anio]

    end

    if params[:form_buscar_registros_titulos] && params[:form_buscar_registros_titulos][:mes].present?

      cond << "mes = ?"
      args << params[:form_buscar_registros_titulos][:mes]

    end

    if params[:form_buscar_registros_titulos_documento].present?

      cond << "documento = ?"
      args << params[:form_buscar_registros_titulos_documento]

    end

    if params[:form_buscar_registros_titulos_nombre_completo].present?

      cond << "nombre_completo ilike ?"
      args << "%#{params[:form_buscar_registros_titulos_nombre_completo]}%"

    end

    if params[:form_buscar_registros_titulos_carrera].present?

      cond << "carrera ilike ?"
      args << "%#{params[:form_buscar_registros_titulos_carrera]}%"

    end

    if params[:form_buscar_registros_titulos_titulo].present?

      cond << "titulo ilike ?"
      args << "%#{params[:form_buscar_registros_titulos_titulo]}%"

    end

    if params[:form_buscar_registros_titulos_numero_resolucion].present?

      cond << "numero_resolucion ilike ?"
      args << "%#{params[:form_buscar_registros_titulos_numero_resolucion]}%"

    end

    if params[:form_buscar_registros_titulos_fecha_resolucion].present?

      cond << "fecha_resolucion = ?"
      args << params[:form_buscar_registros_titulos_fecha_resolucion]

    end

    if params[:form_buscar_registros_titulos_institucion].present?

      cond << "institucion ilike ?"
      args << "%#{params[:form_buscar_registros_titulos_institucion]}%"

    end

    if params[:form_buscar_registros_titulos_tipo_institucion].present?

      cond << "tipo_institucion ilike ?"
      args << "%#{params[:form_buscar_registros_titulos_tipo_institucion]}%"

    end

    if params[:form_buscar_registros_titulos] && params[:form_buscar_registros_titulos][:gobierno_actual].present?

      if params[:form_buscar_registros_titulos][:gobierno_actual] == '2'

        cond << "((anio = 2013 and mes > 7) or (anio > 2013))"
      
      elsif params[:form_buscar_registros_titulos][:gobierno_actual] == '3'
 
        cond << "((anio = 2013 and mes < 8) or (anio < 2013))"

      end

    end

    cond = cond.join(" and ").lines.to_a + args if cond.size > 0

    @registros_titulos = RegistroTitulo.orden_anio_mes.paginate :per_page => 15, :page => params[:page], :conditions => cond

    @registros_titulos_todos = RegistroTitulo.where(cond)
    @total_registros = RegistroTitulo.count 

    if params[:format] == 'csv'

      require 'csv'

      registros_titulos_csv = RegistroTitulo.orden_anio_mes.where(cond)

      csv = CSV.generate do |csv|
        # header row
        csv << ["anio", "mes", "documento", "nombre_completo", "carrera_id", "carrera", "titulo_id", "titulo", "numero_resolucion", "fecha_resolucion", "tipo_institucion_id", "tipo_institucion", "institucion_id","institucion", "gobierno_actual" ]
 
        # data rows
        registros_titulos_csv.each do |rt|
          csv << [rt.anio, rt.mes, rt.documento, rt.nombre_completo, rt.carrera_id, rt.carrera, rt.titulo_id, rt.titulo, rt.numero_resolucion, rt.fecha_resolucion, rt.tipo_institucion_id, rt.tipo_institucion, rt.institucion_id, rt.institucion, rt.gobierno_actual ]
        end

      end
    
      send_data(csv, :type => 'text/csv', :filename => "registros_titulos_#{Time.now.strftime('%Y%m%d')}.csv")

    elsif params[:format] == 'xlsx'
      
      @registros_titulos_xls = RegistroTitulo.orden_anio_mes.where(cond)

      respond_to do |format|
      
        format.xlsx {
          
          columnas = [:anio, :mes, :documento, :nombre_completo, :carrera_id, :carrera, :titulo_id, :titulo, :numero_resolucion, :fecha_resolucion, :tipo_institucion_id, :tipo_institucion, :institucion, :gobierno_actual ] 
          
          send_data RegistroTitulo.orden_anio_mes.where(cond).
            to_xlsx(:columns => columnas, :name => "registros_titulos").to_stream.read, 
            :filename => "registros_titulos_#{Time.now.strftime('%d%m%Y__%H%M')}.xlsx", 
            :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet", 
            disposition: 'attachment'
        }
      
      end

    elsif params[:format] == 'pdf'

      report = ThinReports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'registros_titulos.tlf')

      registros_titulos_pdf = RegistroTitulo.orden_anio_mes.where(cond)
     
      report.start_new_page do |page|
      
        page.item(:fecha_hora).value("Fecha y Hora: #{Time.now.strftime('%d/%m/%Y - %H:%M')}")
    
      end

      registros_titulos_pdf.each do |rt|
      
        report.list(:registros_titulos).add_row do |row|

          row.values  anio: rt.anio,
                      mes: rt.mes,        
                      documento: rt.documento,       
                      nombre_completo: rt.nombre_completo ,       
                      carrera: rt.carrera,       
                      titulo: rt.titulo,       
                      institucion: rt.institucion

        end

      end


      send_data report.generate, filename: "registros_titulos_#{Time.now.strftime('%d%m%Y__%H%M')}.pdf", 
                                 type: 'application/pdf', 
                                 disposition: 'attachment'

    else

      @registros_titulos_json = RegistroTitulo.orden_anio_mes.where(cond)

      respond_to do |f|

        f.js
        f.json {render :json => @registros_titulos_json , :methods => :gobierno_actual}

      end 

    end

  end

  def diccionario

  end

end
