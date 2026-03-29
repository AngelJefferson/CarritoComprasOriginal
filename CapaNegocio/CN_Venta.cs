using CapaDatos;
using CapaEntidad;
using System;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Venta
    {
        private CD_Venta objCapaDato = new CD_Venta();

        public bool RegistrarVenta(Venta obj, out string Mensaje)
        {
            obj.IdTransaccion = Guid.NewGuid().ToString("N").Substring(0, 10).ToUpper();
            return objCapaDato.RegistrarVenta(obj, out Mensaje);
        }

        public Venta ObtenerVenta(string idTransaccion)
        {
            return objCapaDato.ObtenerVenta(idTransaccion);
        }

        public List<DetalleVenta> DetalleVenta(string idTransaccion)
        {
            return objCapaDato.DetalleVenta(idTransaccion);
        }
    }
}
