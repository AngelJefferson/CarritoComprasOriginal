using CapaDatos;
using CapaEntidad;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Ubicacion
    {
        private CD_Ubicacion objCapaDato = new CD_Ubicacion();

        public List<Departamento> ObtenerDepartamentos()
        {
            return objCapaDato.ObtenerDepartamentos();
        }

        public List<Provincia> ObtenerProvincias(string idDepartamento)
        {
            return objCapaDato.ObtenerProvincias(idDepartamento);
        }

        public List<Distrito> ObtenerDistritos(string idProvincia)
        {
            return objCapaDato.ObtenerDistritos(idProvincia);
        }
    }
}
