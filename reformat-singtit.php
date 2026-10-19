<?php
$servername = "10.20.30.1";
$username = "root";
$password = "kehed66";
$dbname = "video_lagu";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sIDMUSIC = "100517400";
$eIDMUSIC = "100518400";
$FOLDER = "SP060%";

#$sql = "SELECT IDMUSIC, SINGER, TITLE FROM masters WHERE TITLE REGEXP BINARY '^[ \.\,\=_\(\)\'0-9A-Za-z-]+$' AND IDMUSIC BETWEEN '$sIDMUSIC' AND '$eIDMUSIC'";
$sql = "SELECT IDMUSIC, SINGER, TITLE FROM masters WHERE PATH LIKE '$FOLDER'";
#$sql = "SELECT IDMUSIC, SINGER, TITLE FROM masters WHERE TITLE REGEXP BINARY '^[0-9A-Z -\']+$'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "IDMUSIC                   : " . $row["IDMUSIC"]. "\n";

        echo "OLD NAME SINGER           : " . $row["SINGER"]. "\n";
        $iSINGER = ucwords($row["SINGER"]);
        $iSINGER = ucwords(strtolower($iSINGER));
        echo "NEW NAME SINGER           : " . $iSINGER. "\n";

        echo "OLD NAME TITLE            : " . $row["TITLE"]. "\n";
        $iTITLE = ucwords($row["TITLE"]);
        $iTITLE = ucwords(strtolower($iTITLE));
        echo "NEW NAME TITLE            : " . $iTITLE. "\n";

        $eSINGER = addslashes($iSINGER);
        $eTITLE  = addslashes($iTITLE);
        $sql = "UPDATE masters SET SINGER = '$eSINGER', TITLE = '$eTITLE' WHERE IDMUSIC = '$row[IDMUSIC]'";
        #$sql = "UPDATE masters SINGER = '$eSINGER' WHERE IDMUSIC = '$row[IDMUSIC]'";
        #$sql = "UPDATE masters TITLE = '$eTITLE' WHERE IDMUSIC = '$row[IDMUSIC]'";

        if (mysqli_query($conn, $sql)) {
            echo "STATUS                    : Update record successfully.\n";
            echo " \n";
        } else {
            echo "STATUS update record      : " . mysqli_error($conn). "\n";
            echo " \n";
        }
    }
} else {
    echo "0 results";
}

$result -> free_result();
$conn->close();
?>
