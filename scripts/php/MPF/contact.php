<?php
// Copyright (C) 2022 Smartspace by DigiVox
// File:            contact.php
// Description:     Digivox Remote Phonebook for Yealink, custom for multi domains
//
// Initial version: unknown <unknown@digivox.com.br>
// Revision:        Edinaldo Lima <edinaldo.lima@digivox.com.br>
// Initial date:    unknown
// Revision date:   2024-04-15
// Version:         1.1
//

// Utilize a URL "https://endereço_http_proxy/yealink/MPF/contact/SiglaCliente" no menu Diretório -> Remote PhoneBook nos aparelhos telefônicos do fabricante Yealink. 
// Observação: alguns modelos podem não ser compatíveis.
//Este script é personalizado para clientes que possuem mais de um domínio separado por unidades.
//No menu PABX -> Agenda Telefônica, preencha o campo "Árvore de cadastro" do contato com a seguinte informação: "SiglaCliente|NomeUnidade", Exemplo: "MPF|Arapiraca - AL"

// Informe o IP do Banco de Dados
$IP_DB = "10.10.1.105";

$empresa = str_replace("/phonebook.xml", "", $_GET["cliente"]);
$con_string_unity = "host=$IP_DB port=5432 dbname=unity user=postgres password=07@banco#postgresql";
$bdcon_unity = pg_connect($con_string_unity);


// Buscar os setores distintos da tabela de contatos.
$result_client = pg_query($bdcon_unity, "SELECT distinct split_part(arvore_cadastro, '|', 2) AS unidade FROM contato WHERE split_part(arvore_cadastro, '|', 1) = '$empresa' AND arvore_cadastro != '' order by unidade");

if (!$result_client) {
  echo "Erro na consulta result_client.<br>";
  exit;
}

//Incio da montagem do arquivo XML, phonebook
header('Content-Type: text/xml');
echo '<?xml version="1.0" encoding="UTF-8"?>';
echo '<YealinkIPPhoneBook>';
echo '<Title>Yealink</Title>';

while ($row = pg_fetch_assoc($result_client)) {
        $group_name = $row['unidade'];
        echo '<Menu Name="' . $group_name . '">';

        // Consulta os contatos pertencentes a esse grupo
        $contacts_result = pg_query($bdcon_unity, "SELECT nome,ramal_1,ramal_2,ramal_3,arvore_cadastro FROM contato WHERE split_part(arvore_cadastro, '|', 1) = '$empresa' AND split_part(arvore_cadastro, '|', 2) = '$group_name' ORDER BY nome");
        if (!$contacts_result) {
                echo "Erro na consulta contacts_result.<br>";
                exit;
        }

        while ($contact_row = pg_fetch_assoc($contacts_result)) {

                echo '<Unit Name="' . $contact_row['nome'] . '" default_photo="" Phone3="' . $contact_row['ramal_3'] . '" Phone2="' . $contact_row['ramal_2'] . '" Phone1="' . $contact_row['ramal_1'] . '"/>' . "\n";
        }

        echo '</Menu>';
  
}
echo '</YealinkIPPhoneBook>';
?>
