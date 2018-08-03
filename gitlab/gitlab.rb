external_url 'http://gitlab.localhost/'

gitlab_rails['gitlab_email_enabled'] = false
gitlab_rails['initial_shared_runners_registration_token'] = "RUNNER_REGISTRATION_TOKEN"

# point to tmpfs
gitlab_rails['env'] = { 'prometheus_multiproc_dir' => '/prometheus' }


# (un)comment to enable/disable
registry_external_url 'http://registry.localhost'
# pages_external_url "http://pages.localhost"
# mattermost_external_url 'http://mattermost.localhost'
