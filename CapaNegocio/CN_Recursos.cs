using CapaDatos;
using CapaEntidad;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Runtime.Remoting.Messaging;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;


namespace CapaNegocio
{
    public class CN_Recursos
    {
        public static string GenerarClave(){

            string clave = Guid.NewGuid().ToString("N").Substring(0,6);
            return clave;
        }

        //Encriptacion de texto en SHA256
        public static string ConvertirSha256(string texto)
        {
            StringBuilder Sb = new StringBuilder();            
            using (SHA256 hash = SHA256.Create())            
            {
                Encoding enc = Encoding.UTF8;
                byte[] result = hash.ComputeHash(enc.GetBytes(texto));
                foreach (byte b in result)
                    Sb.Append(b.ToString("x2"));
            }
            return Sb.ToString();
        }

        public static bool EnviarCorreo(string correoDestino, string asunto, string mensaje)
        {
            bool resultado = false;


            try
            {
                // 1️⃣ Validar que el correo destino sea válido
                if (string.IsNullOrWhiteSpace(correoDestino))
                    throw new Exception("Debe ingresar un correo válido");

                try
                {
                    // Esta línea valida que el formato sea correcto
                    var mailCheck = new MailAddress(correoDestino);
                }
                catch
                {
                    throw new Exception("Correo destino no tiene un formato válido");
                }

                // 2️⃣ Variables con información importante
                string correoSMTP = "ventrayei@gmail.com";   // tu correo
                string claveSMTP = "nhngqeozkuwipfbh";       // contraseña de app
                string hostSMTP = "smtp.gmail.com";          // servidor SMTP
                int puertoSMTP = 587;                        // puerto SMTP

                // 3️⃣ Crear el correo
                MailMessage mail = new MailMessage();
                mail.To.Add(correoDestino);
                mail.From = new MailAddress(correoSMTP);
                mail.Subject = asunto;
                mail.Body = mensaje;
                mail.IsBodyHtml = true;

                // 4️⃣ Configurar el cliente SMTP
                SmtpClient smtp = new SmtpClient(hostSMTP, puertoSMTP);
                smtp.Credentials = new NetworkCredential(correoSMTP, claveSMTP);
                smtp.EnableSsl = true;

                // 5️⃣ Enviar el correo
                smtp.Send(mail);

                return true; // si se envió correctamente
            }
            catch (Exception ex) {

                resultado = false;

            }
            return resultado;

        }


        public static string ConvertirBase64(string ruta, out bool conversion) { 

            string textoBase64 = string.Empty;
            conversion = true;

            try
            {
                byte[] bytes = File.ReadAllBytes(ruta);
                textoBase64 = Convert.ToBase64String(bytes);
            }
            catch {
                conversion = false;
            }

            return textoBase64;

        }

        public List<string> EjecutarPruebasUnitarias()
        {
            List<string> resultados = new List<string>();

            // 1. Test de Categoría (Usa CapaEntidad y CapaNegocio)
            // Se valida que la lógica de negocio bloquee descripciones vacías
            var cat = new Categoria { Descripcion = "" };
            string mensajeCat = "";
            int resCat = new CN_Categoria().Registrar(cat, out mensajeCat);
            resultados.Add(resCat == 0 ? "PASADA: TC01 - Bloqueo de categoría vacía correcto." : "FALLADA: TC01 - Permitió categoría vacía.");

            // 2. Test de Usuarios (Usa CapaNegocio)
            // Se verifica que la lista no sea nula
            var listaU = new CN_Usuarios().Listar();
            resultados.Add(listaU != null ? $"PASADA: TC02 - Listado de usuarios funcional ({listaU.Count} registros)." : "FALLADA: TC02 - Error al recuperar lista de usuarios.");

            // 3. Test de Encriptación (Usa System.Security.Cryptography a través de tu método local)
            string claveOriginal = "Admin123";
            string claveCifrada = ConvertirSha256(claveOriginal);
            resultados.Add(!string.IsNullOrEmpty(claveCifrada) && claveCifrada != claveOriginal ? "PASADA: TC03 - Encriptación SHA256 funcional." : "FALLADA: TC03 - Error en encriptación.");

            // 4. Test de Productos (Usa CapaNegocio)
            var listaP = new CN_Producto().Listar();
            resultados.Add(listaP != null ? "PASADA: TC04 - Conexión y listado de productos correcto." : "FALLADA: TC04 - Error en base de datos al listar productos.");

            // 5. Test de Conexión Base de Datos (Usa System.Data.SqlClient y CapaDatos)
            try
            {
                // Conexion.cn viene de CapaDatos.Conexion
                using (SqlConnection oconexion = new SqlConnection(Conexion.cn))
                {
                    oconexion.Open();
                    resultados.Add("PASADA: TC05 - Conexión física a SQL Server exitosa.");
                }
            }
            catch (Exception ex)
            {
                resultados.Add("FALLADA: TC05 - Error de conexión: " + ex.Message);
            }

            return resultados;
        }

    }
}
