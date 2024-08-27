// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract Departamentos is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public ultimoRequestId;
    string public department;

    address ROUTER = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 DON_ID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint32 GAS_LIMIT = 300000;

    string CODIGO_FUENTE =
        "const department = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://api-colombia.com/api/v1/Department/${department}`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Solicitud fallida');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.name);";

    event Respuesta(
        bytes32 indexed requestId,
        string department
    );
    
    constructor() FunctionsClient(ROUTER) {}

    function enviarSolicitud(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(CODIGO_FUENTE); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        ultimoRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            GAS_LIMIT,
            DON_ID
        );

        return ultimoRequestId;
    }


     function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory
    ) internal override {
        if (ultimoRequestId == requestId) {
            department = string(response);
        }
        // Update the contract's state variables with the response and any errors

        // Emit an event to log the response
        emit Respuesta(requestId, department);
    }

}