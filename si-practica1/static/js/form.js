const form = document.getElementById('formulario')
const inputs = document.querySelectorAll('#formulario input')

const expresions = {
    userName: /^[a-zA-Z0-9]{6,32}$/,
    password: /^.{8,32}/,
    email: /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9_.+-]+\.[a-zA-Z0-9_.+-]+$/,
    creditCard: /^[0-9]{16}$/,
    address: /^[a-zA-Z0-9]{1,50}$/,
};

const fields = {
    userName: false,
    password: false,
    password2: false,
    correo: false,
    creditCard: false,
    address: false,
}

const validarFormulario = (e) => {
    switch (e.target.name) {
        case "userName":
            if (expresions.userName.test(e.target.value)) {
                fields['userName'] = true;
                document.querySelector('#group_userName .formulario__input-error').classList.remove('formulario__input-error-activo');
            } else {
                fields['userName'] = false;
                document.querySelector('#group_userName .formulario__input-error').classList.add('formulario__input-error-activo');

            }
            break;

        case "password":
            if (expresions.password.test(e.target.value)) {
                fields['password'] = true;
                document.querySelector('#group_password .formulario__input-error').classList.remove('formulario__input-error-activo');
            } else {
                fields['password'] = false;
                document.querySelector('#group_password .formulario__input-error').classList.add('formulario__input-error-activo');
            }
            break;
        
        case "password2":
            const inputPassword1 = document.getElementById('password').value;
	        const inputPassword2 = document.getElementById('password2').value;
            if (inputPassword1 == inputPassword2) {
                fields['password2'] = true;
                document.querySelector('#group_password2 .formulario__input-error').classList.remove('formulario__input-error-activo');
            } else {
                fields['password2'] = false;
                document.querySelector('#group_password2 .formulario__input-error').classList.add('formulario__input-error-activo');
            }
            break;

        case "email":
            if (expresions.email.test(e.target.value)) {
                fields['email'] = true;
                document.querySelector('#group_email .formulario__input-error').classList.remove('formulario__input-error-activo');
            } else {
                fields['email'] = false;
                document.querySelector('#group_email .formulario__input-error').classList.add('formulario__input-error-activo');
            }
            break;

        case "creditCard":
            if (expresions.creditCard.test(e.target.value)) {
                fields['creditCard'] = true;
                document.querySelector('#group_creditCard .formulario__input-error').classList.remove('formulario__input-error-activo');
            } else {
                fields['creditCard'] = false;
                document.querySelector('#group_creditCard .formulario__input-error').classList.add('formulario__input-error-activo');
            }
            break;

        case "address":
            if (expresions.address.test(e.target.value)) {
                fields['address'] = true;
                document.querySelector('#group_address .formulario__input-error').classList.remove('formulario__input-error-activo');
            } else {
                fields['address'] = false;
                document.querySelector('#group_address .formulario__input-error').classList.add('formulario__input-error-activo');
            }
            break;
    }
}

inputs.forEach((input) => {
    input.addEventListener('keyup', validarFormulario);
    input.addEventListener('blur', validarFormulario);
});

function enviarFormulario() {
    if (fields.userName && fields.password && fields.password2 && fields.email && fields.creditCard && fields.address) {
        console.log("entra")
        form.submit()
        form.reset()
    }
}

form.addEventListener('submit', (e) => {
    e.preventDefault()
});