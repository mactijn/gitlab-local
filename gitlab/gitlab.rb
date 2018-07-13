external_url 'http://gitlab.localhost/'
gitlab_rails['initial_shared_runners_registration_token'] = "RUNNER_REGISTRATION_TOKEN"

registry_external_url 'http://gitlab.localhost:5000'

registry['registry_http_addr'] = "localhost:5001"
gitlab_rails['registry_api_url'] = "http://localhost:5001"

pages_external_url "http://pages.localhost"
gitlab_pages['inplace_chroot'] = true

gitlab_rails['env'] = { 'prometheus_multiproc_dir' => '/prometheus' }
gitlab_rails['gitlab_email_enabled'] = false
