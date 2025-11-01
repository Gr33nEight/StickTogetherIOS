extension AuthViewModel {
    var nameError: String? { validator.validateName(form.name).message }
    var emailError: String? { validator.validateEmail(form.email).message }
    var passwordError: String? { validator.validatePassword(form.password).message }
    var rePasswordError: String? { validator.validateRePassword(form.password, form.rePassword).message }

    var canSignIn: Bool {
        validator.validateSignIn(email: form.email, password: form.password).allSatisfy { $0.isSuccess }
    }
    var canSignUp: Bool {
        validator.validateSignUp(name: form.name, email: form.email, password: form.password, rePassword: form.rePassword)
            .allSatisfy { $0.isSuccess }
    }
}