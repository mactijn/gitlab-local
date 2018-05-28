external_url 'http://gitlab.localhost/'

### FIXME: We hardcode this key for now.
### See also scripts/register-runner.sh if you wish to replace this.
gitlab_rails['initial_shared_runners_registration_token'] = "DEMO_RUNNER_TOKEN"

registry_external_url 'http://gitlab.localhost:5000'
registry_nginx['enable'] = false
registry['registry_http_addr'] = "0.0.0.0:5000"

gitlab_rails['env'] = { 'prometheus_multiproc_dir' => '/prometheus' }
gitlab_rails['gitlab_email_enabled'] = false
