using CapaDatos;
using CapaEntidad;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Carrito
    {
        private CD_Carrito objCapaDato = new CD_Carrito();

        public bool Agregar(int idCliente, int idProducto, int cantidad, out string Mensaje)
        {
            return objCapaDato.Agregar(idCliente, idProducto, cantidad, out Mensaje);
        }

        public List<Carrito> Listar(int idCliente)
        {
            return objCapaDato.Listar(idCliente);
        }

        public bool Modificar(int idCarrito, int cantidad, out string Mensaje)
        {
            return objCapaDato.Modificar(idCarrito, cantidad, out Mensaje);
        }

        public bool Eliminar(int idCarrito, out string Mensaje)
        {
            return objCapaDato.Eliminar(idCarrito, out Mensaje);
        }

        public int Contar(int idCliente)
        {
            return objCapaDato.Contar(idCliente);
        }
    }
}
