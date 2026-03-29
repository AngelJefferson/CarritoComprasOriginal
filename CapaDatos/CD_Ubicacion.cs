using CapaEntidad;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos
{
    public class CD_Ubicacion
    {
        public List<Departamento> ObtenerDepartamentos()
        {
            List<Departamento> lista = new List<Departamento>();
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_ObtenerDepartamentos", oconexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new Departamento()
                            {
                                IdDepartamento = dr["IdDepartamento"].ToString(),
                                Descripcion = dr["Descripcion"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = new List<Departamento>(); }
            return lista;
        }

        public List<Provincia> ObtenerProvincias(string idDepartamento)
        {
            List<Provincia> lista = new List<Provincia>();
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_ObtenerProvincias", oconexion);
                    cmd.Parameters.AddWithValue("IdDepartamento", idDepartamento);
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new Provincia()
                            {
                                IdProvincia = dr["IdProvincia"].ToString(),
                                Descripcion = dr["Descripcion"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = new List<Provincia>(); }
            return lista;
        }

        public List<Distrito> ObtenerDistritos(string idProvincia)
        {
            List<Distrito> lista = new List<Distrito>();
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_ObtenerDistritos", oconexion);
                    cmd.Parameters.AddWithValue("IdProvincia", idProvincia);
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new Distrito()
                            {
                                IdDistrito = dr["IdDistrito"].ToString(),
                                Descripcion = dr["Descripcion"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = new List<Distrito>(); }
            return lista;
        }
    }
}
