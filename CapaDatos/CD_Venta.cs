using CapaEntidad;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos
{
    public class CD_Venta
    {
        public bool RegistrarVenta(Venta obj, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_RegistrarVenta", oconexion);
                    cmd.Parameters.AddWithValue("IdCliente", obj.IdCliente);
                    cmd.Parameters.AddWithValue("TotalProducto", obj.TotalProducto);
                    cmd.Parameters.AddWithValue("MontoTotal", obj.MontoTotal);
                    cmd.Parameters.AddWithValue("Contacto", obj.Contacto);
                    cmd.Parameters.AddWithValue("IdDistrito", obj.IdDistrito);
                    cmd.Parameters.AddWithValue("Telefono", obj.Telefono);
                    cmd.Parameters.AddWithValue("Direccion", obj.Direccion);
                    cmd.Parameters.AddWithValue("IdTransaccion", obj.IdTransaccion);
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    cmd.ExecuteNonQuery();
                    resultado = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                    Mensaje = cmd.Parameters["Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }
            return resultado;
        }

        public Venta ObtenerVenta(string idTransaccion)
        {
            Venta obj = null;
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_ObtenerVenta", oconexion);
                    cmd.Parameters.AddWithValue("IdTransaccion", idTransaccion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            obj = new Venta()
                            {
                                IdVenta = Convert.ToInt32(dr["IdVenta"]),
                                IdCliente = Convert.ToInt32(dr["IdCliente"]),
                                TotalProducto = Convert.ToInt32(dr["TotalProducto"]),
                                MontoTotal = Convert.ToDecimal(dr["MontoTotal"]),
                                Contacto = dr["Contacto"].ToString(),
                                Telefono = dr["Telefono"].ToString(),
                                Direccion = dr["Direccion"].ToString(),
                                IdTransaccion = dr["IdTransaccion"].ToString(),
                                FechaTexto = Convert.ToDateTime(dr["FechaVenta"]).ToString("dd/MM/yyyy")
                            };
                        }
                    }
                }
            }
            catch { obj = null; }
            return obj;
        }

        public List<DetalleVenta> DetalleVenta(string idTransaccion)
        {
            List<DetalleVenta> lista = new List<DetalleVenta>();
            try
            {
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_DetalleVenta", oconexion);
                    cmd.Parameters.AddWithValue("IdTransaccion", idTransaccion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new DetalleVenta()
                            {
                                IdDetalleVenta = Convert.ToInt32(dr["IdDetalleVenta"]),
                                Cantidad = Convert.ToInt32(dr["Cantidad"]),
                                Total = Convert.ToDecimal(dr["Total"]),
                                oProducto = new Producto()
                                {
                                    Nombre = dr["Nombre"].ToString(),
                                    Precio = Convert.ToDecimal(dr["Precio"])
                                }
                            });
                        }
                    }
                }
            }
            catch { lista = new List<DetalleVenta>(); }
            return lista;
        }
    }
}
