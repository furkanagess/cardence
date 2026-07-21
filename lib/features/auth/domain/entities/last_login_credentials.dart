enum LastLoginMethod { email, phone, linkedin, google, apple }

/// Son başarılı girişte kullanılan kimlik bilgileri (şifre saklanmaz).
class LastLoginCredentials {
  const LastLoginCredentials({
    this.email,
    this.phone,
    this.lastMethod,
  });

  final String? email;
  final String? phone;
  final LastLoginMethod? lastMethod;
}
