// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlquilerSimple {

    // Estructura para almacenar la información de un alquiler
    struct Alquiler {
        address propietario;
        address inquilino;
        uint montoMensual;
        uint duracionMeses;
        uint fechaInicio;
        uint deposito;
        bool activo;
    }

    // Mapeo de la ID del alquiler a la información del alquiler
    mapping(uint => Alquiler) public alquileres;
    uint public proximoIdAlquiler = 1;

    // Evento para registrar un nuevo alquiler
    event NuevoAlquiler(uint idAlquiler, address propietario, address inquilino, uint montoMensual, uint duracionMeses, uint fechaInicio, uint deposito);

    // Función para crear un nuevo alquiler
    function crearAlquiler(address _inquilino, uint _montoMensual, uint _duracionMeses, uint _deposito) public {
        require(_inquilino != address(0), "Direccion del inquilino invalida");
        require(_montoMensual > 0, "El monto mensual debe ser mayor que cero");
        require(_duracionMeses > 0, "La duracion debe ser mayor que cero");
        require(_deposito > 0, "El deposito debe ser mayor que cero");

        uint fechaInicio = block.timestamp; // Fecha actual

        alquileres[proximoIdAlquiler] = Alquiler({
            propietario: msg.sender,
            inquilino: _inquilino,
            montoMensual: _montoMensual,
            duracionMeses: _duracionMeses,
            fechaInicio: fechaInicio,
            deposito: _deposito,
            activo: true
        });

        emit NuevoAlquiler(proximoIdAlquiler, msg.sender, _inquilino, _montoMensual, _duracionMeses, fechaInicio, _deposito);

        proximoIdAlquiler++;
    }

    // Función para que el inquilino pague el alquiler
    function pagarAlquiler(uint _idAlquiler) public payable {
        Alquiler storage alquiler = alquileres[_idAlquiler];
        require(alquiler.activo, "El alquiler no esta activo");
        require(msg.sender == alquiler.inquilino, "Solo el inquilino puede pagar el alquiler");
        require(msg.value == alquiler.montoMensual, "El monto enviado no es correcto");

        // Transferir el pago al propietario
        payable(alquiler.propietario).transfer(msg.value);
    }

    // Función para que el propietario finalice el alquiler y devuelva el depósito
    function finalizarAlquiler(uint _idAlquiler) public {
        Alquiler storage alquiler = alquileres[_idAlquiler];
        require(alquiler.activo, "El alquiler no esta activo");
        require(msg.sender == alquiler.propietario, "Solo el propietario puede finalizar el alquiler");
        require(block.timestamp >= alquiler.fechaInicio + alquiler.duracionMeses * 30 days, "El alquiler aun no ha finalizado"); // Asumiendo un mes de 30 días

        alquiler.activo = false;

        // Devolver el depósito al inquilino
        payable(alquiler.inquilino).transfer(alquiler.deposito);
    }
}