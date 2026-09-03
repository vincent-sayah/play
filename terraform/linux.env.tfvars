  env = {
    # Slug de l'environnement qui apparaitra dans le nom des deploiements
    slug = "dev"

    # L'environnement VRA peut être : "Développement", "Pré-intégration", "Intégration", "Services communs partagés (SVCP)"
    VRA  = "Développement"
  }

  dnsZone = "picsel.defense.gouv.fr"

  # Variable contenant tous les objets VM
  deployment_map = {
front1 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_WEB"

  ### VM
  vm_name        = "XAPIWEB"
  vm_description = "VM web (front)"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["front"]
}

front2 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_HA"

  ### VM
  vm_name        = "XAPIHA"
  vm_description = "VM haproxy (loadbalancer)"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["loadbalancer"]
}

back1 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_PG1"

  ### VM
  vm_name        = "XAPIPG1"
  vm_description = "VM db1 postgresql_primary"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["database", "postgresql", "postgresql_primary"]
}

back2 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_PG2"

  ### VM
  vm_name        = "XAPIPG2"
  vm_description = "VM db2 postgresql_replica"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["database", "postgresql", "postgresql_replica"]
}

back3 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_ES1"

  ### VM
  vm_name        = "XAPIES1"
  vm_description = "VM node1 (elasticsearch_cluster)"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["elasticsearch_cluster", "node1"]
}

back4 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_ES2"

  ### VM
  vm_name        = "XAPIES2"
  vm_description = "VM node2 (elasticsearch_cluster)"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["elasticsearch_cluster", "node2"]
}

back5 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_ES3"

  ### VM
  vm_name        = "XAPIES3"
  vm_description = "VM node3 (elasticsearch_cluster)"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["elasticsearch_cluster", "node3"]
}

front3 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_KIB"

  ### VM
  vm_name        = "XAPIKIB"
  vm_description = "VM kibana oauth2"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["kibana", "oauth2"]
}

front4 = {
  ### COMMUN
  deployment_name = "TF_XAPI_SITE"

  ### VM
  vm_name        = "XAPIPOR"
  vm_description = "VM PORTAILXAPI"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["portailxapi"]
}

obs1 = {
  ### COMMUN
  deployment_name = "TF_XAPI_MN_OBS"

  ### VM
  vm_name        = "XAPIOBS"
  vm_description = "VM obs1 (heartbeat, logstash, otelcol)"

  # Cle de l'item du catalogue sur le broker VRA pour la VM
  catalog_vm_key = "alma8"

  # Gabarit de la VM
  size    = "2 vCPU / 8 Go RAM"
  version = "8.10-V2"

  locale      = "en_US"
  hardening   = "true"
  fast_deploy = "false"

  # Disque supplementaire (30 Go)
  disks = [
    "{\"name\":\"data\",\"size\":30}",
  ]

  # Alias DNS (laisser vide si non utilise)
  dns_name        = ""
  dns_description = ""

  # Groupes Ansible associes (inventaire)
  ansible_group = ["heartbeat", "logstash", "otelcol"]
}
}
