using CapaEntidad;
using CapaNegocio;
using System.Web.Mvc;

namespace CapaPresentacionTienda.Controllers
{
    public class AccesoController : Controller
    {
        public ActionResult Index(string returnUrl = "")
        {
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }

        [HttpPost]
        public ActionResult Login(string correo, string clave, string returnUrl = "")
        {
            string mensaje = string.Empty;
            Cliente oCliente = new CN_Cliente().Login(correo, clave, out mensaje);

            if (oCliente != null)
            {
                Session["IdCliente"] = oCliente.IdCliente;
                Session["NombreCliente"] = oCliente.Nombres + " " + oCliente.Apellidos;

                if (!string.IsNullOrEmpty(returnUrl))
                    return Redirect(returnUrl);

                return RedirectToAction("Index", "Tienda");
            }

            ViewBag.Error = string.IsNullOrEmpty(mensaje) ? "Correo o contrasena incorrectos" : mensaje;
            return View("Index");
        }

        [HttpPost]
        public ActionResult Registrar(Cliente obj)
        {
            string mensaje = string.Empty;
            int resultado = new CN_Cliente().Registrar(obj, out mensaje);

            if (resultado > 0)
            {
                Session["IdCliente"] = resultado;
                Session["NombreCliente"] = obj.Nombres + " " + obj.Apellidos;
                return RedirectToAction("Index", "Tienda");
            }

            ViewBag.Error = mensaje;
            return View("Index");
        }

        public ActionResult CerrarSesion()
        {
            Session.Clear();
            return RedirectToAction("Index", "Tienda");
        }
    }
}
