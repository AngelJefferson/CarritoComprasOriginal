using CapaDatos;
using CapaEntidad;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Cliente
    {
        private CD_Cliente objCapaDato = new CD_Cliente();

        public int Registrar(Cliente obj, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.Nombres))
            { Mensaje = "El nombre del cliente no puede ser vacio"; return 0; }

            if (string.IsNullOrWhiteSpace(obj.Apellidos))
            { Mensaje = "El apellido del cliente no puede ser vacio"; return 0; }

            if (string.IsNullOrWhiteSpace(obj.Correo))
            { Mensaje = "El correo del cliente no puede ser vacio"; return 0; }

            if (string.IsNullOrWhiteSpace(obj.Clave))
            { Mensaje = "La clave del cliente no puede ser vacia"; return 0; }

            obj.Clave = CN_Recursos.ConvertirSha256(obj.Clave);

            return objCapaDato.Registrar(obj, out Mensaje);
        }

        public Cliente Login(string correo, string clave, out string Mensaje)
        {
            Mensaje = string.Empty;
            string claveEncriptada = CN_Recursos.ConvertirSha256(clave);
            return objCapaDato.Login(correo, claveEncriptada, out Mensaje);
        }

        public List<Cliente> Listar()
        {
            return objCapaDato.Listar();
        }
    }
}
