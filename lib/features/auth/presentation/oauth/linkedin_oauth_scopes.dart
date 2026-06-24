import 'package:linkedin_login/linkedin_login.dart';

class LinkedInOpenIdScope extends Scope {
  const LinkedInOpenIdScope() : super('openid');
}

class LinkedInProfileScope extends Scope {
  const LinkedInProfileScope() : super('profile');
}

class LinkedInEmailScope extends Scope {
  const LinkedInEmailScope() : super('email');
}

const linkedInOpenIdScopes = <Scope>[
  LinkedInOpenIdScope(),
  LinkedInProfileScope(),
  LinkedInEmailScope(),
];
