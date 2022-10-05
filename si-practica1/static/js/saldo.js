function AumentarSaldo() {
    var xhr = new XMLHttpRequest();
    var form = new FormData()
    cantidad = document.getElementById('saldo-nuevo').value
    form.append("saldo", cantidad)
    xhr.open("POST", "/AumentarSaldo", true);
    xhr.send(form);
    form.delete;

    xhr.onreadystatechange = function() {
        if(xhr.status == 200 && xhr.readyState == 4) {
            if(xhr.responseText == '0') {
                alert("OPERACION DENEGADA");
            } else {
                var saldo_actual = document.getElementById('saldo-actual').value;
                var saldo_nuevo = parseInt(saldo_actual) + parseInt(cantidad)
                document.getElementById("saldo-actual").value = saldo_nuevo
                document.getElementById('ver-saldo').innerHTML = "Saldo actual: " + String(saldo_nuevo) + '\xa0';
                
            }
        }
    }
}