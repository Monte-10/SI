function AddMovie(id, number) {
    var form = new FormData()
    form.append("movie_id", id)
    form.append("number", number)
    var xhr = new XMLHttpRequest();
    url = "/AddMovie"
    xhr.open("POST", url, true);
    xhr.send(form);
    form.delete;
}


function LoadMovieFromId(id){
    console.log("Entra")
    var form = new FormData()
    console.log(id)
    form.append("movie_id", id)
    var xhr = new XMLHttpRequest();
    url = "/CargarCounter"
    xhr.open("POST", url, true);
    xhr.send(form);
    form.delete;

    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            html = "<input class='product-number-button' type='number' min='1' max='10' step='1' value='" + xhr.responseText + "' onchange= \"AddMovie("+String(id)+",value)\">"
            document.getElementById('product-number_'+String(id)).insertAdjacentHTML('beforeend', html);


        }
    }
}