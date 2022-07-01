provider "josso" {
  org_name      = "atricore"
  endpoint      = "http://localhost:8081/atricore-rest/services"
  client_id     = "idbus-f2f7244e-bbce-44ca-8b33-f5c0bde339f7"
  client_secret = "7oUHlv(HLT%vxK4L"
}

resource "iamtf_identity_appliance" "testacc-ida01" {
  name        = "testacc-ida01"
  namespace   = "com.atricore.idbus.testacc.ida01"
  description = "Appliance #1"
  location    = "http://localhost:8081"
}

resource "iamtf_idvault" "sso-users" {
  ida  = iamtf_identity_appliance.testacc-ida01.name
  name = "sso-users"
}

resource "iamtf_idp" "idp1" {
  ida  = iamtf_identity_appliance.testacc-ida01.name
  name = "idp1"

  keystore {
    resource = filebase64("../../acctest-data/sp.p12")
    password = "changeme"
  }

  id_sources = [iamtf_idvault.sso-users.name]
  depends_on = [
    iamtf_idvault.sso-users
  ]

}

resource "iamtf_execenv_tomcat" "tc85" {
  ida         = iamtf_identity_appliance.testacc-ida01.name
  name        = "tc85"
  description = "Tomcat 8.5"
  version     = "8.5"
  depends_on  = [iamtf_idp.idp1]
}

resource "iamtf_app_agent" "partnerapp1" {
  ida          = iamtf_identity_appliance.testacc-ida01.name
  name         = "partnerapp1"
  app_location = "http://localhost:8080/partnerapp"

  keystore {
    resource = filebase64("../../acctest-data/sp.p12")
    password = "changeme"
  }

  idp {
    name         = iamtf_idp.idp1.name
    is_preferred = true
  }

  exec_env = iamtf_execenv_tomcat.tc85.name

  depends_on = [
    iamtf_idp.idp1, iamtf_execenv_tomcat.tc85
  ]

}


