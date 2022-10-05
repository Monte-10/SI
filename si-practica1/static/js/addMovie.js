function AddMovie(id) {
    var form = new FormData()
    form.append("movie_id", id)
    var xhr = new XMLHttpRequest();
    url = "/"
    xhr.open("POST", url, true);
    xhr.send(form);
    form.delete;

    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            location.replace("/")

        }
    }
}