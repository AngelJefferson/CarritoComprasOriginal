using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using CapaEntidad;
using CapaNegocio;

namespace CapaPresentacionAdmin.Controllers
{
    public class AccesoController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult CambiarClave()
        {
            return View();
        }

        public ActionResult Restablecer()
        {
            return View();
        }


        [HttpPost]
        public ActionResult Index(string correo, string clave)
        {
            Usuario oUsuario = new CN_Usuarios().Listar().Where(u => u.Correo == correo && u.Clave == CN_Recursos.ConvertirSha256(clave)).FirstOrDefault();

            if(oUsuario == null)
            {
                ViewBag.Error = "Correo o contraseña no correcta";
                return View();
            }

            if(oUsuario.Reestablecer)
            {
                Session["Usuario"] = oUsuario;
                return RedirectToAction("CambiarClave", "Acceso");
            }

            Session["Usuario"] = oUsuario;
            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        public ActionResult CambiarClave(string claveActual, string nuevaClave, string confirmarClave)
        {
            Usuario oUsuario = (Usuario)Session["Usuario"];

            if(oUsuario == null)
            {
                return RedirectToAction("Index", "Acceso");
            }

            if(string.IsNullOrEmpty(nuevaClave) || nuevaClave != confirmarClave)
            {
                ViewBag.Error = "Las contraseñas no coinciden";
                return View();
            }

            if(nuevaClave.Length < 6)
            {
                ViewBag.Error = "La nueva contraseña debe tener al menos 6 caracteres";
                return View();
            }

            if(CN_Recursos.ConvertirSha256(claveActual) != oUsuario.Clave)
            {
                ViewBag.Error = "La contraseña actual es incorrecta";
                return View();
            }

            string mensaje;
            bool resultado = new CN_Usuarios().CambiarClave(oUsuario.IdUsuario, CN_Recursos.ConvertirSha256(nuevaClave), out mensaje);

            if(resultado)
            {
                Session["Usuario"] = null;
                ViewBag.Error = null;
                ViewBag.Success = "Contraseña actualizada correctamente. Inicie sesión con su nueva contraseña.";
                return View("Index");
            }
            else
            {
                ViewBag.Error = mensaje;
                return View();
            }
        }

        public ActionResult CerrarSesion()
        {
            Session["Usuario"] = null;
            return RedirectToAction("Index", "Acceso");
        }

        [HttpPost]
        public ActionResult RecuperarClave(string correo)
        {
            if (string.IsNullOrEmpty(correo))
            {
                ViewBag.RecuperarError = "Debe ingresar un correo electrónico";
                return View("Index");
            }

            var oUsuario = new CN_Usuarios().Listar().Where(u => u.Correo == correo).FirstOrDefault();

            if (oUsuario == null)
            {
                ViewBag.RecuperarError = "No existe un usuario con ese correo electrónico";
                return View("Index");
            }

            string mensaje;
            bool resultado = new CN_Usuarios().ReestablecerClave(oUsuario.IdUsuario, oUsuario.Correo, out mensaje);

            if (resultado)
            {
                ViewBag.RecuperarSuccess = "Se ha enviado una nueva contraseña a tu correo electrónico.";
            }
            else
            {
                ViewBag.RecuperarError = mensaje;
            }

            return View("Index");
        }
    }
}