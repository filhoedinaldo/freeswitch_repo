// Copyright (C) 2022 Smartspace by DigiVox
// File:            contact.php
// Description:     Digivox Remote Phonebook for Yealink
//
// Initial version: unknown <unknown@digivox.com.br>
// Revision:        Edinaldo Lima <edinaldo.lima@digivox.com.br>
// Initial date:    unknown
// Revision date:   2024-04-15
// Version:         1.1
//

// Modo de usar: Utilizar a URL https://endereço_http_proxy/yealink/contact/domain_uuid, no menu Directorio -> Remote PhoneBook, nos aparelhos telefônicos do fabricante Yealink (alguns modelos não funcionam).

$IP_DB = "10.10.1.105";

$domain_uuid = str_replace("/phonebook.xml", "", $_GET["domain_uuid"]);
$con_string_unity = "host=10.10.1.105 port=5432 dbname=unity user=postgres password=07@banco#postgresql";
$bdcon_unity = pg_connect($con_string_unity);

$result = pg_query($bdcon_unity, "select distinct local as dep from contato where domain_uuid = '$domain_uuid' and local != '' order by dep");
if (!$result) {
  echo "Erro na consulta result.<br>";
  exit;
}

header('Content-Type: text/xml');
echo '<?xml version="1.0" encoding="UTF-8"?>';
echo '<YealinkIPPhoneBook>';
echo '<Title>Yealink</Title>';

while ($row = pg_fetch_assoc($result)) {
        $group_name = $row['dep'];
        echo '<Menu Name="' . $group_name . '">';


        // Consulta os contatos pertencentes a esse grupo
        $contacts_result = pg_query($bdcon_unity, "select nome,ramal_1,ramal_2,ramal_3,local from contato where domain_uuid = '$domain_uuid' and local = '$group_name' order by nome");
        if (!$contacts_result) {
          echo "Erro na consulta contact_result.<br>";
          exit;
        }

        while ($contact_row = pg_fetch_assoc($contacts_result)) {

                echo '<Unit Name="' . $contact_row['nome'] . '" default_photo="" Phone3="' . $contact_row['ramal_3'] . '" Phone2="' . $contact_row['ramal_2'] . '" Phone1="' . $contact_row['ramal_1'] . '"/>' . "\n";
        }

        echo '</Menu>';
}

echo '</YealinkIPPhoneBook>';
?>
