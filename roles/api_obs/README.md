# install-api-health
**Ce rôle installe et configure une API Observabilité pour le suivi des SI**
**Ce rôle est donné à titre d'exemple**

# Mise en Place #
 1. Télécharger ce projet à partir de tag le plus récent.
 2. Créer un dossier nommé 'api_obs' au sein de dossier 'roles' de votre projet de déploiement.
 3. Copier / coller l'intégralité du contenu de l'élement téléchargé vers votre dossier 'api_obs'.
 4. S'assurer que les variables définies ci-dessous sont renseignées et correctement définies.
 5. Définir la liste des services nécessaires, via la variable ```services_api_obs```. 
 6. Appeler le rôle préalablement importé dans un playbook.

# 1 - Pré-requis
- Apache
- PHP

# 2 - Présentation
Ce projet permet d'installer et configurer une API observabilité faite en php.
Cette API permet d'une part d'exposer des données de gouvernance, d'autre part d'exposer un status global et un status par service.
La status global est calculé en fonction d'un code HTTP rendu par l'url renseignée dans la variable 'api_service_url_si', si le status rendu est un 200, le status global sera considéré comme UP, 500 sera considéré comme DOWN, 503 sera considéré comme MAINTENANCE, les autres codes http rendront un status UNKNOW.

# 3 - Variables obligatoires
Les variables référencées ci-dessous doivent impérativement être renseignées, sans quoi le rôle ne sera pas capable d'amener l'API à un état fonctionnel.

## Observation
Les variables suivantes sont des métadonnées relatives au SI concerné par l'API :<br>
https://forge.intradef.gouv.fr/plugins/git/portail-service-desk-and/api-observabilite?a=blob&hb=e2aefb94cb85714743ccd2822aa511ac5c2d62bb&h=e432a206fa79c26e9ea8b09c9bde781f3641b2bb&f=observabilite.yaml<br>
Le respect du contrat d'interface ci-dessus est necessaire.<br>
(Ces variables devraient déja être renseignées, car elles correspondent au fichier info.yml)<br>

| Variable | Description | Exemple |
| -------- | ----------- | ------- |
| nom | Nom du SI | ROC NG |
| trigramme | Trigramme du projet | ROZ |
| version | Version du SI | 1.0.0 |
| date_version | Date de sortie de la version | 2024-12-31T17:32:28Z |
| environnement | Environnement de déploiement de l'API |  - developpement <br/> - integration <br/> - preproduction <br/> - production <br/> - secours <br/> - formation <br/>|
| classification_max_donnees | Classification des données | DR |
| mentions | Liste des mentions |  - SF <br/> - CP <br/> - EP <br/> |
| niveau_arr | tbd | I3 |
| niveau_service | Niveau de service du SI | infogerance |
| direction_systeme_information | tbd | RSH |
| direction_application | tbd | EMA/DD |
| type_homologation | tbd | DEF |
| date_fin_homologation | Date de fin de l'homologation | 2017-07-21T17:32:28Z |
| date_fin_hebergement | (Optionnelle) Date de fin de l'hebergement | 2017-07-21T17:32:28Z |

## Services
Les variables suivantes sont des données relatives aux services utilisés par le SI :

| Variable | Description | Exemple |
| -------- | ----------- | ------- |
| services_api_obs | Liste des services  utilisés par le SI. <br/> Ces services sont des entrées à 3 attributs (url, nom, port), soit des listes d'entrées similaires. | sgbdr:<br/> - url: 'https://MONSITE.picsel.defense.gouv.fr '<br/>  &nbsp;&nbsp;  nom: 'sgbdr 1 terre mag'<br/>&nbsp;&nbsp; port: '3306' &nbsp;<br/> - url: 'https://MONSITE.picsel.defense.gouv.fr'<br/>  &nbsp;&nbsp;  nom: 'sgbdr 2 terre mag' <br/>&nbsp;&nbsp; port: '3306'|
| api_service_url_si | URL vers le front du SI, cette url doit rendre un status http 200 afin que l'API émette un status 'UP' | https://MONSITE.picsel.defense.gouv.fr |

## Autres
<b> Les variables suivantes sont necessaires dû aux différences entre l'artifactory picsel et c1np

| Variable | Description | Exemple |
| -------- | ----------- | ------- |
| <b> repository_downloads_path_for_api_observability | <b> Chemin vers le package de l'api pour Picsel | <b> https://{{ FQDN_BRM_SERVER }}/artifactory/commun-generic/download/health-generic/download/health |
| <b>repository_downloads_path_for_api_observability | <b> Chemin vers le package de l'api pour C1NP (à commenter sur picsel, à placer dans inventories/prod et preprod) |<b> https://{{ FQDN_BRM_SERVER }}/artifactory/{{ identifiant_zp_repo }}-generic  |

# 4 - Variables optionnelles
| Variable | Description | Valeur par defaut |
| -------- | ----------- | ------- |
| api_obs_health_archive_url | URL MEDUSA pointant vers l'API | {{ repository_downloads_path_for_api_observability }}/{{ api_obs_health_binary }} |
| api_obs_website_main_path | Dossier du server web | /var/www/html (Apache) |
| api_obs_application_owner | Owner du dossier de l'API | apache  |
| api_obs_service_name | Nom du service du serveur web | httpd (Apache) |
| api_obs_info_file_name | Nom du fichier contenant les MetaDate | info.yml |
| api_obs_service_file_name | Nom du fichier contenant les services | services.yml |
| api_obs_info_file_path | Path vers le fichier info | ./{{ api_obs_info_file_name }} |
| api_obs_service_file_path | Path vers le fichier services | ./{{ api_obs_service_file_name }}  |
| api_obs_health_alias_url | Alias de l'url pour le endpoints health | /v1/api/observability/health |
| api_obs_info_alias_url | Alias de l'url pour le endpoints info | /v1/api/observability/info |
| api_obs_service_maintenance_keyword | Valeur rendue en cas de maintenance | site en maintenance |
| api_obs_archive_path | Emplacement dans lequel l'API sera placée après récupération sur MEDUSA | {{ api_obs_website_main_path }}/api_health.zip |
| api_obs_health_path | Emplacement du dossier contenant le code source php de l'API | {{ api_obs_website_main_path }}/api_health |

# 5 - Troubleshooting
**Statut UNKNOW**

Le statut "unknow" est rendu si le code HTTP retourné n'est pas 200/500/503, si une redirection est effectuée à l'URL cible, cela retournera une 300, qui causera un statut unknow. Pour cela, s'assurer que l'URL cible correspond à l'URL finale de destination.<br>

Afin de mieux comprendre le comportement actuel, utiliser curl afin d'obtenir le code HTTP retourné.<br>
<br>
| Depuis l'hôte hébergeant l'API |
| -------- |
| curl -I http://SERVICE.picsel.defense.gouv.fr |

**404 ou ERR_CONNECT_TIMEOUT**

S'assurer que le front du SI fonctionne. <br>
Vérifier la valeur des Alias dans la configuration Apache.

**URL Health / Info**

L'alias généré doit contenir /info ou /health à la fin de son URL, sans cela, l'API ne pourra pas traiter la requête. 

**Le Système d'information est hors service**

- S'assurer que les données du fichier ```info.yml``` sont conformes aux attendus de l'API Observabilité :
(https://forge.intradef.gouv.fr/plugins/git/portail-service-desk-and/api-observabilite?a=blob&hb=98a6f142e7a3754f2221c402e0aeb6761d5e16f9&h=bdc6915a242c8d93bf693068f57c7fac41ece69c&f=observabilite.yaml) 


- Vérifier les exceptions levées par php sur la machine (RHEL :/var/log/php-fpm/www-error.log)
