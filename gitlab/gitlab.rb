external_url 'http://gitlab.localhost/'
gitlab_rails['initial_shared_runners_registration_token'] = "RUNNER_REGISTRATION_TOKEN"

registry_external_url 'http://gitlab.localhost:5000'
registry_nginx['listen_addresses'] = ['10.12.14.16']

gitlab_rails['env'] = { 'prometheus_multiproc_dir' => '/prometheus' }
gitlab_rails['gitlab_email_enabled'] = false
