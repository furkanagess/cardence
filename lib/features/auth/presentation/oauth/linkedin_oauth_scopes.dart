/// LinkedIn OAuth scope listesi.
///
/// OIDC (`openid profile email`) temel oturum için zorunlu.
/// `r_profile_basicinfo` ve Plus kapsamları [Verified on LinkedIn] ürünü ile
/// profil URL, pozisyon, şirket ve okul bilgisini sağlar.
/// LinkedIn Developer Portal → Products → Verified on LinkedIn ekleyin.
const linkedInAuthorizationScope =
    'openid profile email r_profile_basicinfo '
    'r_most_recent_education r_primary_current_experience';
