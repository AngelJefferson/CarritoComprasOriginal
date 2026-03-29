using CapaEntidad;
using CapaNegocio;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace CapaPresentacionTienda.Controllers
{
    public class TiendaController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public JsonResult ListarCategorias()
        {
            List<Categoria> lista = new CN_Categoria().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ListarProductos(int idCategoria = 0, string busqueda = "")
        {
            List<Producto> lista = new CN_Producto().Listar();
            lista = lista.Where(p => p.Activo && p.Stock > 0).ToList();

            if (idCategoria > 0)
                lista = lista.Where(p => p.oCategoria.IdCategoria == idCategoria).ToList();

            if (!string.IsNullOrEmpty(busqueda))
                lista = lista.Where(p => p.Nombre.ToLower().Contains(busqueda.ToLower())).ToList();

            string[] imagenesProductos = {
                "https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400",
                "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400",
                "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400",
                "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
                "https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400",
                "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
                "https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400",
                "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400",
                "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400",
                "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400",
                "https://images.unsplash.com/photo-1534888589157-c6a4de686306?w=400",
                "https://images.unsplash.com/photo-1626806819282-2c1dc01a5e2c?w=400",
                "https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400",
                "https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400",
                "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400",
                "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400",
                "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=400",
                "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400",
                "https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=400",
                "https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=400"
            };

            int index = 0;
            foreach (var p in lista)
            {
                if (!string.IsNullOrEmpty(p.RutaImagen) && !string.IsNullOrEmpty(p.NombreImagen))
                {
                    string ruta = System.IO.Path.Combine(p.RutaImagen, p.NombreImagen);
                    bool conversion;
                    p.Base64 = CN_Recursos.ConvertirBase64(ruta, out conversion);
                    p.Extension = conversion ? System.IO.Path.GetExtension(p.NombreImagen) : "";
                }
                else
                {
                    p.Base64 = "";
                    p.Extension = ".jpg";
                    p.NombreImagen = imagenesProductos[index % imagenesProductos.Length];
                }
                index++;
            }

            return Json(new { data = lista.Select(p => new {
                p.IdProducto, p.Nombre, p.Descripcion, p.Precio, p.Stock, p.Base64, p.Extension,
                Marca = p.oMarca.Descripcion,
                Categoria = p.oCategoria.Descripcion,
                UrlImagen = p.NombreImagen
            })}, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AgregarCarrito(int idProducto, int cantidad = 1)
        {
            if (Session["IdCliente"] == null)
                return Json(new { resultado = false, mensaje = "LOGIN_REQUIRED" });

            int idCliente = (int)Session["IdCliente"];
            string mensaje = string.Empty;
            bool resultado = new CN_Carrito().Agregar(idCliente, idProducto, cantidad, out mensaje);
            return Json(new { resultado, mensaje });
        }

        [HttpGet]
        public JsonResult ListarCarrito()
        {
            if (Session["IdCliente"] == null)
                return Json(new { data = new List<object>() }, JsonRequestBehavior.AllowGet);

            int idCliente = (int)Session["IdCliente"];
            List<Carrito> lista = new CN_Carrito().Listar(idCliente);

            return Json(new { data = lista.Select(c => new {
                c.IdCarrito, c.Cantidad,
                c.oProducto.IdProducto, c.oProducto.Nombre,
                c.oProducto.Precio, c.oProducto.Stock,
                SubTotal = c.oProducto.Precio * c.Cantidad
            })}, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ModificarCarrito(int idCarrito, int cantidad)
        {
            string mensaje = string.Empty;
            bool resultado = new CN_Carrito().Modificar(idCarrito, cantidad, out mensaje);
            return Json(new { resultado, mensaje });
        }

        [HttpPost]
        public JsonResult EliminarCarrito(int idCarrito)
        {
            string mensaje = string.Empty;
            bool resultado = new CN_Carrito().Eliminar(idCarrito, out mensaje);
            return Json(new { resultado, mensaje });
        }

        [HttpGet]
        public JsonResult ContarCarrito()
        {
            if (Session["IdCliente"] == null)
                return Json(new { cantidad = 0 }, JsonRequestBehavior.AllowGet);

            int idCliente = (int)Session["IdCliente"];
            int cantidad = new CN_Carrito().Contar(idCliente);
            return Json(new { cantidad }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Checkout()
        {
            if (Session["IdCliente"] == null)
                return RedirectToAction("Index", "Acceso", new { returnUrl = "/Tienda/Checkout" });

            return View();
        }

        [HttpGet]
        public JsonResult ObtenerDepartamentos()
        {
            var lista = new CN_Ubicacion().ObtenerDepartamentos();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerProvincias(string idDepartamento)
        {
            var lista = new CN_Ubicacion().ObtenerProvincias(idDepartamento);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerDistritos(string idProvincia)
        {
            var lista = new CN_Ubicacion().ObtenerDistritos(idProvincia);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ProcesarVenta(string contacto, string telefono, string idDistrito, string direccion)
        {
            if (Session["IdCliente"] == null)
                return Json(new { resultado = false, mensaje = "Sesion expirada" });

            int idCliente = (int)Session["IdCliente"];
            List<Carrito> carrito = new CN_Carrito().Listar(idCliente);

            if (carrito.Count == 0)
                return Json(new { resultado = false, mensaje = "El carrito esta vacio" });

            Venta obj = new Venta()
            {
                IdCliente = idCliente,
                TotalProducto = carrito.Sum(c => c.Cantidad),
                MontoTotal = carrito.Sum(c => c.oProducto.Precio * c.Cantidad),
                Contacto = contacto,
                IdDistrito = idDistrito,
                Telefono = telefono,
                Direccion = direccion
            };

            string mensaje = string.Empty;
            bool resultado = new CN_Venta().RegistrarVenta(obj, out mensaje);

            return Json(new { resultado, mensaje, idTransaccion = obj.IdTransaccion });
        }

        public ActionResult Confirmacion(string id)
        {
            ViewBag.IdTransaccion = id;
            return View();
        }

        [HttpGet]
        public JsonResult ObtenerVenta(string idTransaccion)
        {
            Venta venta = new CN_Venta().ObtenerVenta(idTransaccion);
            List<DetalleVenta> detalle = new CN_Venta().DetalleVenta(idTransaccion);

            return Json(new {
                venta = venta != null ? new {
                    venta.IdTransaccion, venta.Contacto, venta.Telefono,
                    venta.Direccion, venta.MontoTotal, venta.TotalProducto, venta.FechaTexto
                } : null,
                detalle = detalle.Select(d => new {
                    d.oProducto.Nombre, d.oProducto.Precio, d.Cantidad, d.Total
                })
            }, JsonRequestBehavior.AllowGet);
        }
    }
}
