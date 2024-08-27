// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentHashRegistry {

    // Mapeo de hashes de documentos a booleanos (true si existe, false si no)
    mapping(uint256 => bool) public documentHashes;

    // Función para registrar un nuevo hash de documento
    function registerDocumentHash(uint256 _documentHash) public {
        // Verificar si el hash ya existe
        require(documentHashes[_documentHash] == false, "El hash del documento ya esta registrado.");

        // Registrar el hash del documento
        documentHashes[_documentHash] = true;
    }

    // Función para verificar si un hash de documento ya existe
    function verifyDocumentHash(uint256 _documentHash) public view returns (bool) {
        // Devolver true si el hash existe, false si no
        return documentHashes[_documentHash];
    }
}