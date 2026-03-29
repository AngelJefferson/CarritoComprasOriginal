using CapaEntidad;
using CapaNegocio;
using System;
using System.Collections.Generic;
using System.Diagnostics; // Necesario para Debug.WriteLine

namespace CapaPresentacionAdmin.DBCARRITO.Tests
{
    public class PruebasUnitarias
    {
        public List<string> EjecutarPruebasUnitarias()
        {
            List<string> resultados = new List<string>();
            var servicioCategoria = new CN_Categoria();
            string mensaje;

            // Prueba 1: Validación de descripción vacía
            // Tu lógica en CN_Categoria ya tiene: if (string.IsNullOrEmpty(obj.Descripcion)...)
            int resultado1 = servicioCategoria.Registrar(new Categoria { Descripcion = "" }, out mensaje);
            resultados.Add(resultado1 == 0 ? "PASADA: Bloqueó descripción vacía" : "FALLADA: Permitió descripción vacía");

            // Prueba 2: Encriptación SHA256
            string hash = CN_Recursos.ConvertirSha256("admin123");
            bool hashOk = !string.IsNullOrEmpty(hash) && hash.Length == 64; // SHA256 siempre tiene 64 caracteres
            resultados.Add(hashOk ? "PASADA: Hash generado correctamente" : "FALLADA: Error en encriptación");

            // Prueba 3: Generación de Clave
            string clave = CN_Recursos.GenerarClave();
            resultados.Add(clave.Length == 6 ? "PASADA: Clave de 6 caracteres" : "FALLADA: Longitud de clave incorrecta");

            // Imprimir en la ventana de Salida de Visual Studio
            foreach (var res in resultados)
            {
                Debug.WriteLine(res);
            }

            return resultados;
        }
    }
}