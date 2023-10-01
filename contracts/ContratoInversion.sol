// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ContratoInversion{

    // Estructura de datos para representar a un inversionista
    struct Inversionista {
        uint8 edad;
        uint256 ingreso_anual;
        uint8 educacion_universitaria;
        uint8 estado_civil;
        uint8 hijos;
        uint8 educacion_financiera;
        uint256 [] eth_inversion;
        address [] inversiones;
        int8 tolerancia;
        bool registrado;
    }

    // Mapeo para asociar direcciones de Ethereum con inversionistas
    mapping(address => Inversionista) private inversionistas;

    // Evento que se emite cuando un nuevo inversionista se registra
    event NuevoInversionista(address indexed inversionista, uint256 saldoInicial);

    event Inversion(address indexed cuenta, uint256 cantidad);

    event Retiro(address indexed cuenta, uint256 cantidad);

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Función para registrar un nuevo inversionista
    function registrarInversionista() public {
        require(!inversionistas[msg.sender].registrado, "Ya estas registrado como inversionista.");
        
        Inversionista memory nuevoInversionista = Inversionista({
            edad: 0,
            ingreso_anual: 0,
            educacion_universitaria: 0,
            estado_civil: 0,
            hijos: 0,
            educacion_financiera: 0,
            eth_inversion: new uint256[](0),
            inversiones: new address[](0),
            tolerancia: 0,
            registrado: true
        });

        inversionistas[msg.sender] = nuevoInversionista;

        emit NuevoInversionista(msg.sender, 0);
    }

    function invertir(address _proyecto) public payable {
        uint256 minimunUSD = 1 * 10**18;
        require(msg.value > 0, "No se puede invertir 0 ether");
        require(getConversionRate(msg.value) >= minimunUSD, "La inversion minima es de 1 USD");
        inversionistas[msg.sender].eth_inversion.push(msg.value);
        inversionistas[msg.sender].inversiones.push(_proyecto);
        emit Inversion(msg.sender, msg.value);
    }


    function retirar_inversion(uint256 num_inv) public{
        uint256 cantidad = uint256(inversionistas[msg.sender].inversiones.length);
        require(cantidad > 0, "No hay inversiones para retirar");
        delete inversionistas[msg.sender].inversiones[num_inv-1];
        payable(msg.sender).transfer(inversionistas[msg.sender].eth_inversion[num_inv-1]);
        delete inversionistas[msg.sender].eth_inversion[num_inv-1];
        emit Retiro(msg.sender, cantidad);
    }

    function getInversiones(uint256 _num_inv) public view returns (address) {
        return inversionistas[msg.sender].inversiones[_num_inv-1];
    }

    function getInversionesEth(uint256 _num_inv) public view returns (uint256) {
        return inversionistas[msg.sender].eth_inversion[_num_inv-1];
    }

    function getTolerancia() public view returns (int8) {
        return inversionistas[msg.sender].tolerancia;
    }

    function getPrice() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10000000000;
    }

    function getConversionRate(uint256 ethAmount) private view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 1 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price) + 1;
    }
}