using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using CapaEntidad;
using CapaNegocio;
using ClosedXML.Excel;

namespace CapaPresentacionAdmin.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Usuarios()
        {
            return View();
        }

        public ActionResult Clientes()
        {
            return View();
        }

        [HttpGet]
        public JsonResult ListarClientes()
        {
            List<Cliente> olista = new CN_Cliente().Listar();
            return Json(new { data = olista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ListarUsuarios()
        {
            List<Usuario> olista = new List<Usuario>();

            olista = new CN_Usuarios().Listar();

            return Json(new { data = olista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult GuardarUsuario(Usuario objeto)
        {
            object resultado;
            string mensaje = string.Empty;

            if (objeto.IdUsuario == 0)
            {
                resultado = new CN_Usuarios().Registrar(objeto, out mensaje);
            }
            else
            {
                resultado = new CN_Usuarios().Editar(objeto, out mensaje);
            }

            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult EliminarUsuario(int id)
        {
            bool respuesta = false;
            string mensaje = string.Empty;

            respuesta = new CN_Usuarios().Eliminar(id, out mensaje);

            return Json(new { resultado = respuesta, mensaje = mensaje }, JsonRequestBehavior.AllowGet);

        }

        [HttpGet]
        public JsonResult ListaReporte(string fechainicio, string fechafin, string idtransaccion)
        {

            List<Reporte> olista = new List<Reporte>();

            olista = new CN_Reporte().Ventas(fechainicio, fechafin, idtransaccion);

            return Json(new { data = olista }, JsonRequestBehavior.AllowGet);

        }

        [HttpGet]
        public JsonResult CorrerTests()
        {
            // Se instancia la capa de negocio para acceder a los tests
            // Asegúrate de que EjecutarPruebasUnitarias() retorne una List<string> o similar
            List<string> resultados = new CN_Recursos().EjecutarPruebasUnitarias();

            // Retornamos los resultados en formato JSON
            return Json(new { data = resultados }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult VistaDashBoard() {
            DashBoard objeto = new CN_Reporte().VerDashBoard();
            return Json(new { resultado = objeto }, JsonRequestBehavior.AllowGet);

        }

        [HttpPost]
        public FileResult ExportarVenta(string fechainicio, string fechafin, string idtransaccion) { 
        
            List<Reporte> olista = new List<Reporte>();
            olista = new CN_Reporte().Ventas(fechainicio, fechafin, idtransaccion);

            DataTable dt = new DataTable();

            dt.Locale = new System.Globalization.CultureInfo("es-DO");
            dt.Columns.Add("Fecha Ventua", typeof(string));
            dt.Columns.Add("Cliente", typeof(string));
            dt.Columns.Add("Producto", typeof(string));
            dt.Columns.Add("Precio", typeof(decimal));
            dt.Columns.Add("Cantidad", typeof(int));
            dt.Columns.Add("Total", typeof(decimal));
            dt.Columns.Add("IdTransaccion", typeof(string));


            foreach (Reporte rp in olista) {
                dt.Rows.Add(new object[]
                {
                    rp.FechaVenta,
                    rp.Cliente,
                    rp.Producto,
                    rp.Precio,
                    rp.Cantidad,
                    rp.Total,
                    rp.IdTransaccion,
                });          
            }

            dt.TableName = "Datos";

            using (XLWorkbook wb = new XLWorkbook())
            {
                wb.Worksheets.Add(dt);
                using (MemoryStream stream = new MemoryStream()) {
                    wb.SaveAs(stream);
                    return File(stream.ToArray(), "aplication/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "ReporteVenta" + DateTime.Now.ToString() + ".xlsx");


                }

            }

        }

    }

}