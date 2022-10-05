from typing import Counter, List
from flask import Flask, render_template, redirect, request, session, make_response
from hashlib import blake2b
import os
import hashlib
import json
import random

app = Flask(__name__)

app.secret_key = 'esto-es-una-clave-muy-secreta'


@app.route("/AumentarSaldo", methods=['POST'])
def AumentarSaldo():
    saldo = request.form['saldo']
    print(saldo)
    saldo = int(saldo)
    userName = session['user']

    if saldo <= 0:
        return "0"

    fileName = "public_html/usuarios/%s/datos.dat" % userName

    with open(fileName, 'r') as file:
        lines = file.readlines()

    saldo += int(lines[4][7:])
    lines[4] = "Saldo: %d\n" % saldo

    with open(fileName, "w") as file:
        file.writelines(lines)

    return "1"


@app.route("/CargarCounter", methods=['POST'])
def LoadCounter():
    id = int(request.form['movie_id'])
    id -= 1
    counter = session[str(id)]
    session[str(id)] = counter
    return str(counter)


@app.route("/AddMovie", methods=['POST'])
def AddMovie():
    if request.method == "POST":
        id = int(request.form["movie_id"])
        id -= 1
        amount = int(request.form["number"])
        session[str(id)] = amount
    return "4"


def checkUserOnline():
    if "user" in session:
        return session["user"]
    return None


def createUser() -> bool:
    userName = request.form['userName']
    password = request.form['password']
    email = request.form['email']
    creditCard = request.form['creditCard']
    address = request.form['address']

    dir_path = "public_html/usuarios/%s" + user

    try:
        os.makedirs(dir_path, exist_ok=False)
    except FileExistsError:
        return False

    with open(dir_path + "/datos.dat", 'w') as file:
        file.write('UserName: ' + userName + '\n')
        encrypted_password = hashlib.blake2b(
            password.encode('utf-8')).hexdigest()
        file.write('Password: ' + encrypted_password + '\n')
        file.write('Email: ' + email + '\n')
        file.write('CreditCard: ' + creditCard + '\n')
        file.write('Saldo: %d \n' % (100 * random.random()))
        file.write('Dirección: %s' % address)
    return True


def validateLogin() -> bool:
    userName = request.form['userName']
    password = request.form['password']

    try:
        file = open('public_html/usuarios/%s/datos.dat' % userName)
        data = file.readlines()
    except OSError:
        return False

    encrypted_password = hashlib.blake2b(
        password.encode('utf-8')).hexdigest()
    if userName == data[0][10:-1] and encrypted_password == data[1][10:-1]:
        return True
    else:
        return False


def addToCart(peliculas) -> None:
    films = session["films"]
    id = int(request.form['movie_id'])
    id -= 1
    film = peliculas[id]
    if film not in films:
        films.append(film)
        session["films"] = films
        session[str(id)] = 1
    else:
        num = session[str(id)]
        num += 1
        session[str(id)] = num


def filterByTitle(catalogue):
    titulo = request.form["filtro"]
    films_filtered = list()

    for film in catalogue:
        if titulo.lower() in film['titulo'].lower():
            films_filtered.append(film)

    return films_filtered


def readJSON(jsonToRead):

    try:
        file = open(jsonToRead, encoding='UTF-8')
        catalogue_data = file.read()
        catalogue = json.loads(catalogue_data)
        return catalogue['peliculas']
    except OSError:
        return None


@app.route("/", methods=['GET', 'POST'])
def PaginaPrincipal():

    peliculas = readJSON('catalogue.json')

    if session.get("films") is None:
        session["films"] = list()

    if request.method == 'POST':

        if "/Register" in request.referrer:
            if createUser() is False:
                return render_template("app/Register.html")
        elif "/Film/" in request.referrer:
            addToCart(peliculas)
            return "4"
        else:
            peliculas = filterByTitle(peliculas)

    return render_template("app/PaginaPrincipal.html", movies=peliculas, user=checkUserOnline())


@app.route("/<categoria>")
def FilterByCategory(categoria):

    films_filtered = list()

    films = readJSON('catalogue.json')

    for film in films:
        if film['categoria'] == categoria:
            films_filtered.append(film)

    return render_template("app/PaginaPrincipal.html", movies=films_filtered, user=checkUserOnline())


@app.route("/Login", methods=['GET', 'POST'])
def Login():

    if session.get("user") is None:
        if request.method == 'POST':
            res = validateLogin()
            if res is True:
                user = request.form["userName"]
                session["user"] = user
                session["flag"] = True
                return redirect("/")

    userName = request.cookies.get("userID")
    if userName is None:
        userName = ''

    return render_template("app/Login.html", userName=userName)


@app.route("/LogOut")
def LogOut():
    user = session["user"]
    session.pop("user", None)

    films = session["films"]
    for film in films:
        id = str(film['id']-1)
        session.pop(id, None)
    session.pop("films", None)

    resp = make_response(redirect("/"))
    resp.set_cookie('userID', user)
    return resp


@app.route("/Register")
def Register():
    return render_template("app/Register.html")


@app.route("/Film/<id>")
def Film(id):
    catalogue = readJSON('catalogue.json')
    id = int(id)
    movie = catalogue[id-1]
    return render_template("app/FilmDetail.html", movie=movie, actors=movie["actores"], user=checkUserOnline())


@app.route("/Cart", methods=['GET', 'POST'])
def Cart():

    lista = session["films"]

    if request.method == "POST":
        id = request.form['id']
        for film in lista:
            if int(film['id']) == int(id):
                lista.remove(film)
                session["film"] = lista

    return render_template("app/Cart.html", lista=lista, user=checkUserOnline())


@app.route("/Historial")
def Historial():
    user = session["user"]
    dir_Path = "public_html/usuarios/%s/" % user
    json_file = dir_Path + "historial.json"
    historial = readJSON(json_file)
    userData = dir_Path + "datos.dat"
    with open(userData, "r") as file:
        lines = file.readlines()
    saldo = lines[4][7:]
    return render_template("app/Historial.html", historial=historial, saldo=saldo, user=checkUserOnline())


@app.route("/Success")
def Success():

    user = session["user"]
    dir_path = "public_html/usuarios/" + user

    films_list = session["films"]
    films = {"peliculas": films_list}
    json_file = dir_path + '/historial.json'

    data = None
    if os.path.exists(json_file) is True:
        with open(json_file, 'r') as file:
            data = json.load(file)
        for film in films["peliculas"]:
            if film in data["peliculas"] is False:
                data["peliculas"].append(film)
    else:
        data = films

    with open(json_file, 'w') as file:
        json.dump(data, file, indent=4)

    with open(dir_path + "/datos.dat", "r") as file:
        lines = file.readlines()

    saldo = lines[4]
    saldoDisponible = int(saldo[7:])

    precioUnaPelicula = 0.00
    cantidadPelicula = 0
    precioVariasPeliculas = 0.00
    precioTotal = 0.00

    for movie in films_list:
        precioUnaPelicula = movie['precio']
        idPelicula = str(movie['id'] - 1)
        cantidadPelicula = session[idPelicula]
        precioVariasPeliculas = precioUnaPelicula * cantidadPelicula
        precioTotal += precioVariasPeliculas

    if saldoDisponible > precioTotal:
        saldoDisponible -= precioTotal
        lines[4] = "Saldo: %d \n" % saldoDisponible
        with open(dir_path + "/datos.dat", "w") as file:
            file.writelines(lines)

    for film in films_list:
        id = str(film['id'] - 1)
        session.pop(id, None)
    session.pop("films", None)

    return render_template('app/Success.html'), {"Refresh": "1; url=/"}


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=True)
