using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaEntidad
{
    //    CREATE TABLE DETALLE_VENTA(
    //IdDetalleVenta int primary key identity,
    //IdVenta int references Venta(IdVenta),
    //IdProducto int references PRODUCTO(IdProducto),
    //Cantidad int,
    //Total Decimal(10,2)
    //)

    public class DetalleVenta
    {
        public int IdDetalleVenta { get; set; }
        public int IdVenta { get; set; }
        public Producto oProducto { get; set; }
        public int Cantidad { get; set; }
        public decimal Total { get; set; }
        public string IdTransaccion { get; set; }
    }
}
