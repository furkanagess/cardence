/// LinkedIn OAuth scope listesi.
///
/// Yalnızca "Sign In with LinkedIn using OpenID Connect" ürünüyle gelen ve
/// her uygulamada varsayılan onaylı olan temel kapsamlar istenir:
/// `openid profile email`.
///
/// NOT: `r_profile_basicinfo`, `r_most_recent_education`,
/// `r_primary_current_experience` gibi genişletilmiş kapsamlar LinkedIn'in
/// "Verified on LinkedIn" ürününün onayını gerektirir. Bu ürün uygulamaya
/// eklenip onaylanmadan istenirse LinkedIn, kullanıcı giriş yapmadan
/// authorization isteğini reddeder ve "Sorry, an error occurred" hata
/// sayfasını gösterir. Ürün onaylandığında bu kapsamlar tekrar eklenebilir;
/// backend ek alanları zaten best-effort olarak (eksikse atlayarak) işler.
const linkedInAuthorizationScope = 'openid profile email';
