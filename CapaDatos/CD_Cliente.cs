using CapaEntidad;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos
{
    public class CD_Cliente
    {
        public int Registrar(Cliente obj, out string Mensaje)
        {
            int idautogenerado = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_RegistrarCliente", oconexion);
                    cmd.Parameters.AddWithValue("Nombres", obj.Nombres);
                    cmd.Parameters.AddWithValue("Apellidos", obj.Apellidos);
                    cmd.Parameters.AddWithValue("Correo", obj.Correo);
                    cmd.Parameters.AddWithValue("Clave", obj.Clave);
                    cmd.Parameters.AddWithValue("Provincia", obj.Provincia ?? (object)DBNull.Value);
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    cmd.ExecuteNonQuery();
                    idautogenerado = Convert.ToInt32(cmd.Parameters["Resultado"].Value);
                    Mensaje = cmd.Parameters["Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                idautogenerado = 0;
                Mensaje = ex.Message;
            }
            return idautogenerado;
        }

        public Cliente Login(string correo, string clave, out string Mensaje)
        {
            Cliente obj = null;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_LoginCliente", oconexion);
                    cmd.Parameters.AddWithValue("Correo", correo);
                    cmd.Parameters.AddWithValue("Clave", clave);
                    cmd.Parameters.Add("Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    cmd.ExecuteNonQuery();

                    int idCliente = Convert.ToInt32(cmd.Parameters["Resultado"].Value);
                    Mensaje = cmd.Parameters["Mensaje"].Value.ToString();

                    if (idCliente > 0)
                    {
                        using (SqlCommand cmd2 = new SqlCommand("SELECT IdCliente, Nombres, Apellidos, Correo FROM CLIENTE WHERE IdCliente = @id", oconexion))
                        {
                            cmd2.Parameters.AddWithValue("@id", idCliente);
                            cmd2.CommandType = CommandType.Text;
                            using (SqlDataReader dr = cmd2.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    obj = new Cliente()
                                    {
                                        IdCliente = Convert.ToInt32(dr["IdCliente"]),
                                        Nombres = dr["Nombres"].ToString(),
                                        Apellidos = dr["Apellidos"].ToString(),
                                        Correo = dr["Correo"].ToString()
                                    };
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                obj = null;
                Mensaje = ex.Message;
            }
            return obj;
        }

        public List<Cliente> Listar()
        {
            List<Cliente> lista = new List<Cliente>();
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("SELECT IdCliente, Nombres, Apellidos, Correo, ISNULL(Provincia, 'No especificada') as Provincia, FechaRegistro FROM CLIENTE ORDER BY FechaRegistro DESC", oconexion);
                    cmd.CommandType = CommandType.Text;
                    oconexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new Cliente()
                            {
                                IdCliente = Convert.ToInt32(dr["IdCliente"]),
                                Nombres = dr["Nombres"].ToString(),
                                Apellidos = dr["Apellidos"].ToString(),
                                Correo = dr["Correo"].ToString(),
                                Provincia = dr["Provincia"].ToString(),
                                FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"])
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<Cliente>();
            }
            return lista;
        }
    }
}
