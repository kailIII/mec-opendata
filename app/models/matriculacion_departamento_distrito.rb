class MatriculacionDepartamentoDistrito < ActiveRecord::Base
  
  self.table_name = 'matriculaciones_departamentos_distritos'
  
  acts_as_xlsx 

  scope :orden_dep_dis, :order => 'nombre_departamento, nombre_distrito'

end
