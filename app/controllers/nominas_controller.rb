# -*- encoding : utf-8 -*-
class NominasController< ApplicationController
  before_filter :redireccionar_uri

  def index
    
    respond_to do |f|

      f.html {render :layout => 'layouts/application'}
  
    end
  end

  def diccionario
    
    require 'json'
    file = File.read("#{Rails.root}/app/assets/javascripts/diccionario/nomina_administrativos.json")
    diccionario = JSON.parse(file)
    @diccionario_nomina_administrativos = clean_json(diccionario)

    if params[:format] == 'json'
      
      generate_json_table_schema(@diccionario_nomina_administrativos)

    elsif params[:format] == 'pdf'
      
      send_data(generate_pdf(@diccionario_nomina_administrativos, params[:nombre]), :filename => "diccionario_nomina_administrativos.pdf", :type => "application/pdf")

    end

  end

  def lista

    cond = []
    args = []
    estados = []

    if params[:form_buscar_nominas] && params[:form_buscar_nominas][:ano_periodo_pago].present?

      cond << "ano_periodo_pago = ?"
      args << params[:form_buscar_nominas][:ano_periodo_pago]

    end

    if params[:form_buscar_nominas] && params[:form_buscar_nominas][:mes_periodo_pago].present?

      cond << "mes_periodo_pago = ?"
      args << params[:form_buscar_nominas][:mes_periodo_pago]

    end

    if params[:form_buscar_nominas_codigo_trabajador].present?

      cond << "rtrim(codigo_trabajador, ' ') = ?"
      args << params[:form_buscar_nominas_codigo_trabajador]

    end

    if params[:form_buscar_nominas_nombre_trabajador].present?

      cond << "rtrim(nombre_trabajador, ' ') ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_nominas_nombre_trabajador])}%"

    end

    if params[:form_buscar_nominas_nombre_objeto_gasto].present?

      cond << "sin_acentos(nombre_objeto_gasto || codigo_objeto_gasto) ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_nominas_nombre_objeto_gasto])}%"

    end

    if params[:form_buscar_nominas_estado].present?

      cond << "estado ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_nominas_estado])}%"

    end

    if params[:form_buscar_nominas_antiguedad_administrativo].present?

      cond << "antiguedad_administrativo ilike ?"
      args << "%#{params[:form_buscar_nominas_antiguedad_administrativo]}%"

    end

    if params[:form_buscar_nominas_asignacion].present?

      cond << "asignacion #{params[:form_buscar_nominas_asignacion_operador]} ?"
      args << params[:form_buscar_nominas_asignacion]

    end

    if params[:form_buscar_nominas][:sexo].present?

      cond << "sexo = ?"
      args << params[:form_buscar_nominas][:sexo]

    end

    cond = cond.join(" and ").lines.to_a + args if cond.size > 0
    
    if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
      @nomina = VNomina.es_administrativo.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond).paginate(page: params[:page], per_page: 15)
    else
      @nomina = VNomina.es_administrativo.ordenado_anio_mes_nombre.where(cond).paginate(page: params[:page], per_page: 15)
    end

    first_time = Nomina.select("ano_periodo_pago", "mes_periodo_pago").es_administrativo.order(codigo_periodo_pago: :desc).limit(1)
    puts first_time

    #@total_registros_encontrados = VNomina.count :conditions => cond
    #@total_registros = VNomina.count 

    if params[:format] == 'csv'

      require 'csv'
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        nominas_csv = Nomina.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        nominas_csv = Nomina.ordenado_anio_mes_nombre.where(cond)
      end

      csv = CSV.generate do |csv|
        # header row
        csv << ["mes_periodo_pago", "ano_periodo_pago", "codigo_concepto_nomina", "nombre_concepto_nomina", "codigo_trabajador", "nombre_trabajador", "anhos_antiguedad_administrativo", "meses_antiguedad_administrativo", "anhos_antiguedad_docente", "meses_antiguedad_docente", "codigo_puesto", "numero_tipo_presupuesto_puesto", "codigo_dependencia", "nombre_dependencia", "codigo_cargo", "nombre_cargo", "codigo_categoria_rubro", "monto_categoria_rubro", "cantidad", "asignacion", "sexo"]
 
        # data rows
        nominas_csv.each do |n|
          csv << [n.mes_periodo_pago, n.ano_periodo_pago, n.codigo_concepto_nomina, n.nombre_concepto_nomina, n.codigo_trabajador, n.nombre_trabajador, n.anhos_antiguedad_administrativo, n.meses_antiguedad_administrativo, n.anhos_antiguedad_docente, n.meses_antiguedad_docente, n.codigo_puesto, n.numero_tipo_presupuesto_puesto, n.codigo_dependencia, n.nombre_dependencia, n.codigo_cargo, n.nombre_cargo, n.codigo_categoria_rubro, n.monto_categoria_rubro, n.cantidad, n.asignacion, n.sexo]
        end

      end
    
      send_data(csv, :type => 'text/csv', :filename => "nomina_#{Time.now.strftime('%Y%m%d')}.csv")

    elsif params[:format] == 'xlsx'
      
      respond_to do |format|
      
        format.xlsx {
          
          columnas = [:mes_periodo_pago, :ano_periodo_pago, :codigo_concepto_nomina, :nombre_concepto_nomina, :codigo_trabajador, :nombre_trabajador, :anhos_antiguedad_administrativo, :meses_antiguedad_administrativo, :anhos_antiguedad_docente, :meses_antiguedad_docente, :codigo_puesto, :numero_tipo_presupuesto_puesto, :codigo_dependencia, :nombre_dependencia, :codigo_cargo, :nombre_cargo, :codigo_categoria_rubro, :monto_categoria_rubro, :cantidad, :asignacion, :sexo]
          
          if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
            send_data Nomina.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond).to_xlsx(:columns => columnas).to_stream.read, 
            :filename => "nomina_#{Time.now.strftime('%d%m%Y__%H%M')}.xlsx", 
            :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet", 
            disposition: 'attachment'
          else
            send_data Nomina.ordenado_anio_mes_nombre.where(cond).to_xlsx(:columns => columnas).to_stream.read, 
            :filename => "nomina_#{Time.now.strftime('%d%m%Y__%H%M')}.xlsx", 
            :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet", 
            disposition: 'attachment'
          end
        }
      
      end

    elsif params[:format] == 'pdf'

      report = ThinReports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'funcionario_administrativo.tlf')
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        nomina = Nomina.es_administrativo.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        nomina = Nomina.es_administrativo.ordenado_anio_mes_nombre.where(cond)
      end
   
      report.layout.config.list(:nomina) do
        
        # Define the variables used in list.
        use_stores :total_page => 0

        # Dispatched at list-page-footer insertion.
        events.on :page_footer_insert do |e|
          e.section.item(:asignacion_total).value(e.store.total_page)
          #e.store.total_report += e.store.total_page
          #e.store.total_page = 0;
        end

        #Dispatched at list-footer insertion.
        events.on :footer_insert do |e|
          #e.section.item(:jerarquia).value(solicitud.jerarquia.descripcion)
          #e.section.item(:solicitante).value(solicitud.solicitante.nombre_completo)
        end
    
      end

      report.start_new_page do |page|
      
        page.item(:fecha_hora).value("Fecha y Hora: #{Time.now.strftime('%d/%m/%Y - %H:%M')}")
    
      end

      nomina.each do |n|
      
        report.list(:nomina).add_row do |row|

          row.values  mes_periodo_pago: n.mes_periodo_pago,
            ano_periodo_pago: n.ano_periodo_pago,
            codigo_trabajador: n.codigo_trabajador,        
            nombre_trabajador: n.nombre_trabajador,       
            nombre_objeto_gasto: "#{n.nombre_objeto_gasto} (#{n.codigo_objeto_gasto})",       
            estado: obtener_estado_funcionario(n.numero_tipo_presupuesto_puesto),
            antiguedad: "#{n.anhos_antiguedad_administrativo} año/s y #{n.meses_antiguedad_administrativo} mes/es",       
            nombre_concepto_nomina: n.nombre_concepto_nomina,       
            nombre_dependencia: n.nombre_dependencia_efectiva,       
            nombre_cargo: n.nombre_cargo_efectivo,       
            codigo_categoria_rubro: n.codigo_categoria_rubro,       
            monto_categoria_rubro: n.monto_categoria_rubro,       
            cantidad: n.cantidad.to_i,     
            asignacion: n.asignacion,
            monto_devuelto: n.monto_devuelto
            #,sexo: n.monto_devuelto

        end

        report.page.list(:nomina) do |list|
        
          list.store.total_page +=  n.asignacion

        end

      end


      send_data report.generate, filename: "funcionario_administrativo_#{Time.now.strftime('%d%m%Y__%H%M')}.pdf", 
        type: 'application/pdf', 
        disposition: 'attachment'

    elsif params[:format] == 'md5_csv'
      
      filename = "funcionarios_administrativos" + params[:form_buscar_nominas][:ano_periodo_pago] + "_" + params[:form_buscar_nominas][:mes_periodo_pago]
      path_file = "#{Rails.root}/public/data/" + filename + ".csv"
      send_data(generate_md5(path_file), :filename => filename+".md5", :type => "application/txt")

    else

      #nomina = Nomina.ordenado_anio_mes_nombre.where(cond)
      #@nomina_todos = VNomina.ordenado_anio_mes_nombre.where(cond)
      
      respond_to do |f|

        f.js
        #f.json {render :json => nomina }

      end 

    end

  end

  def detalles

    @nomina = Nomina.es_administrativo.where("id_trabajador = ? and id_objeto_gasto = ? 
    and ano_periodo_pago = ? and mes_periodo_pago = ?", 
      params[:id_trabajador], params[:id_objeto_gasto], params[:ano_periodo_pago], params[:mes_periodo_pago])

    respond_to do |f|

      f.js

    end

  end

  def docentes_diccionario
    
    require 'json'
    file = File.read("#{Rails.root}/app/assets/javascripts/diccionario/nomina_docentes.json")
    diccionario = JSON.parse(file)
    @diccionario_nomina_docentes = clean_json(diccionario)

    if params[:format] == 'json'
      
      generate_json_table_schema(@diccionario_nomina_docentes)

    elsif params[:format] == 'pdf'
      
      send_data(generate_pdf(@diccionario_nomina_docentes, params[:nombre]), :filename => "diccionario_nomina_docentes.pdf", :type => "application/pdf")

    end

  end
  
  def docentes

    respond_to do |f|

      f.html {render :layout => 'application'}

    end

  end

  def docentes_lista

    cond = []
    args = []
    estados = []

    if params[:form_buscar_nominas] && params[:form_buscar_nominas][:ano_periodo_pago].present?

      cond << "ano_periodo_pago = ?"
      args << params[:form_buscar_nominas][:ano_periodo_pago]

    end

    if params[:form_buscar_nominas] && params[:form_buscar_nominas][:mes_periodo_pago].present?

      cond << "mes_periodo_pago = ?"
      args << params[:form_buscar_nominas][:mes_periodo_pago]

    end

    if params[:form_buscar_nominas_codigo_trabajador].present?

      cond << "rtrim(codigo_trabajador, ' ') = ?"
      args << params[:form_buscar_nominas_codigo_trabajador]

    end

    if params[:form_buscar_nominas_nombre_trabajador].present?

      cond << "rtrim(nombre_trabajador, ' ') ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_nominas_nombre_trabajador])}%"

    end

    if params[:form_buscar_nominas_nombre_objeto_gasto].present?

      cond << "sin_acentos(nombre_objeto_gasto || codigo_objeto_gasto) ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_nominas_nombre_objeto_gasto])}%"

    end

    if params[:form_buscar_nominas_estado].present?

      cond << "estado ilike ?"
      args << "%#{quita_acentos(params[:form_buscar_nominas_estado])}%"

    end

    if params[:form_buscar_nominas_antiguedad_docente].present?

      cond << "antiguedad_docente ilike ?"
      args << "%#{params[:form_buscar_nominas_antiguedad_docente]}%"

    end

    if params[:form_buscar_nominas_numero_matriculacion].present?

      cond << "numero_matriculacion = ?"
      args << params[:form_buscar_nominas_numero_matriculacion]

    end

    if params[:form_buscar_nominas_asignacion].present?

      cond << "asignacion #{params[:form_buscar_nominas_asignacion_operador]} ?"
      args << params[:form_buscar_nominas_asignacion]

    end

    if params[:form_buscar_nominas][:sexo].present?

      cond << "sexo = ?"
      args << params[:form_buscar_nominas][:sexo]

    end

    cond = cond.join(" and ").lines.to_a + args if cond.size > 0
    
    if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
      @nomina = VNomina.es_docente.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond).paginate(page: params[:page], per_page: 15)
    else
      @nomina = VNomina.es_docente.ordenado_anio_mes_nombre.where(cond).paginate(page: params[:page], per_page: 15)
    end

    #@total_registros_encontrados = VNomina.count :conditions => cond
    #@total_registros = VNomina.count 

    if params[:format] == 'csv'

      require 'csv'
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        nominas_csv = Nomina.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        nominas_csv = Nomina.ordenado_anio_mes_nombre.where(cond)
      end

      csv = CSV.generate do |csv|
        # header row
        csv << ["mes_periodo_pago", "ano_periodo_pago", "codigo_concepto_nomina", "nombre_concepto_nomina", "codigo_trabajador", "nombre_trabajador", "anhos_antiguedad_administrativo", "meses_antiguedad_administrativo", "anhos_antiguedad_docente", "meses_antiguedad_docente", "codigo_puesto", "numero_tipo_presupuesto_puesto", "codigo_dependencia", "nombre_dependencia", "codigo_cargo", "nombre_cargo", "codigo_categoria_rubro", "monto_categoria_rubro", "cantidad", "asignacion", "sexo"]
 
        # data rows
        nominas_csv.each do |n|
          csv << [n.mes_periodo_pago, n.ano_periodo_pago, n.codigo_concepto_nomina, n.nombre_concepto_nomina, n.codigo_trabajador, n.nombre_trabajador, n.anhos_antiguedad_administrativo, n.meses_antiguedad_administrativo, n.anhos_antiguedad_docente, n.meses_antiguedad_docente, n.codigo_puesto, n.numero_tipo_presupuesto_puesto, n.codigo_dependencia, n.nombre_dependencia, n.codigo_cargo, n.nombre_cargo, n.codigo_categoria_rubro, n.monto_categoria_rubro, n.cantidad, n.asignacion, n.sexo]
        end

      end
    
      send_data(csv, :type => 'text/csv', :filename => "nomina_#{Time.now.strftime('%Y%m%d')}.csv")

    elsif params[:format] == 'xlsx'
      
      respond_to do |format|
      
        format.xlsx {
          
          columnas = [:mes_periodo_pago, :ano_periodo_pago, :codigo_concepto_nomina, :nombre_concepto_nomina, :codigo_trabajador, :nombre_trabajador, :anhos_antiguedad_administrativo, :meses_antiguedad_administrativo, :anhos_antiguedad_docente, :meses_antiguedad_docente, :codigo_puesto, :numero_tipo_presupuesto_puesto, :codigo_dependencia, :nombre_dependencia, :codigo_cargo, :nombre_cargo, :codigo_categoria_rubro, :monto_categoria_rubro, :cantidad, :asignacion, :sexo]
          
          if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
            send_data Nomina.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond).to_xlsx(:columns => columnas).to_stream.read, 
            :filename => "nomina_#{Time.now.strftime('%d%m%Y__%H%M')}.xlsx", 
            :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet", 
            disposition: 'attachment'
          else
            send_data Nomina.ordenado_anio_mes_nombre.where(cond).to_xlsx(:columns => columnas).to_stream.read, 
            :filename => "nomina_#{Time.now.strftime('%d%m%Y__%H%M')}.xlsx", 
            :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet", 
            disposition: 'attachment'
          end
        }
      
      end

    elsif params[:format] == 'pdf'

      report = ThinReports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'funcionario_docente.tlf')
      
      if params[:ordenacion_columna].present? && params[:ordenacion_direccion].present?
        nomina = Nomina.es_docente.order(params[:ordenacion_columna] + " " + params[:ordenacion_direccion]).where(cond)
      else
        nomina = Nomina.es_docente.ordenado_anio_mes_nombre.where(cond)
      end
   
      report.layout.config.list(:nomina) do
        
        # Define the variables used in list.
        use_stores :total_page => 0

        # Dispatched at list-page-footer insertion.
        events.on :page_footer_insert do |e|
          e.section.item(:asignacion_total).value(e.store.total_page)
          #e.store.total_report += e.store.total_page
          #e.store.total_page = 0;
        end

        #Dispatched at list-footer insertion.
        events.on :footer_insert do |e|
          #e.section.item(:jerarquia).value(solicitud.jerarquia.descripcion)
          #e.section.item(:solicitante).value(solicitud.solicitante.nombre_completo)
        end
    
      end

      report.start_new_page do |page|
      
        page.item(:fecha_hora).value("Fecha y Hora: #{Time.now.strftime('%d/%m/%Y - %H:%M')}")
    
      end

      nomina.each do |n|
      
        report.list(:nomina).add_row do |row|

          row.values  mes_periodo_pago: n.mes_periodo_pago,
            ano_periodo_pago: n.ano_periodo_pago,
            codigo_trabajador: n.codigo_trabajador,        
            nombre_trabajador: n.nombre_trabajador,       
            nombre_objeto_gasto: "#{n.nombre_objeto_gasto} (#{n.codigo_objeto_gasto})",       
            estado: obtener_estado_funcionario(n.numero_tipo_presupuesto_puesto),
            antiguedad: "#{n.anhos_antiguedad_docente} año/s y #{n.meses_antiguedad_docente} mes/es",       
            nombre_concepto_nomina: n.nombre_concepto_nomina,       
            nombre_dependencia: n.nombre_dependencia_efectiva,       
            nombre_cargo: n.nombre_cargo_efectivo,       
            codigo_categoria_rubro: n.codigo_categoria_rubro,       
            monto_categoria_rubro: n.monto_categoria_rubro,       
            cantidad: n.cantidad.to_i, 
            numero_matriculacion: n.numero_matriculacion,       
            asignacion: n.asignacion
            #,sexo: n.sexo

        end

        report.page.list(:nomina) do |list|
        
          list.store.total_page +=  n.asignacion

        end

      end


      send_data report.generate, filename: "funcionario_docente_#{Time.now.strftime('%d%m%Y__%H%M')}.pdf", 
        type: 'application/pdf', 
        disposition: 'attachment'

    elsif params[:format] == 'md5_csv'
      
      filename = "funcionarios_docentes" + params[:form_buscar_nominas][:ano_periodo_pago] + "_" + params[:form_buscar_nominas][:mes_periodo_pago]
      path_file = "#{Rails.root}/public/data/" + filename + ".csv"
      send_data(generate_md5(path_file), :filename => filename+".md5", :type => "application/txt")

    else


      #nomina = Nomina.ordenado_anio_mes_nombre.where(cond)
      #@nomina_todos = VNomina.ordenado_anio_mes_nombre.where(cond)
      
      respond_to do |f|

        f.js
        #f.json {render :json => nomina }

      end 

    end

  end

  def docentes_detalles

    @nomina = Nomina.es_docente.where("id_trabajador = ? and id_objeto_gasto = ? and ano_periodo_pago = ? 
    and mes_periodo_pago = ?", params[:id_trabajador], params[:id_objeto_gasto],
      params[:ano_periodo_pago], params[:mes_periodo_pago])

    respond_to do |f|

      f.js

    end

  end
  
    
  
  def docentes_doc
    @cnomina = VNomina.order('mes_periodo_pago DESC').find_by_codigo_trabajador(params[:codigo_trabajador])
    @dnomina = VNomina.where("codigo_trabajador = ? ",@cnomina.codigo_trabajador) if @cnomina.present? 
    
    respond_to do |f|

      f.html
      #f.js

    end
    
         
  end
   
  def administrativo_doc
   
    @adminnomina = VNomina.order('mes_periodo_pago DESC').find_by_codigo_trabajador(params[:codigo_trabajador])
    @adnomina = VNomina.where("codigo_trabajador = ? ",@adminnomina.codigo_trabajador) if @adminnomina.present? 
    
    respond_to do |f|

      f.html

    end
    
         
  end
  

end
