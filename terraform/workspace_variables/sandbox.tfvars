# PaaS
paas_app_environment       = "sandbox"
paas_cf_space              = "bat-prod"
paas_web_app_memory        = 512
paas_web_app_instances     = 1
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "micro-5_x"
paas_worker_app_stopped    = true
paas_clock_app_command     = "sleep 180s" # to be changed after migrating to PaaS 
paas_worker_app_command    = "sleep 180s" # to be changed after migrating to PaaS

# KeyVault
key_vault_resource_group    = "s121p01-shared-rg"
key_vault_name              = "s121p01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-SANDBOX"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-SANDBOX"

# StatusCake
statuscake_alerts = {
  apply-sandbox = {
    website_name   = "Apply-Teacher-Training-Sandbox"
    website_url    = "https://sandbox.apply-for-teacher-training.service.gov.uk/integrations/monitoring/all"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-sandbox-check = {
    website_name   = "Apply-Teacher-Training-Check-Sandbox"
    website_url    = "https://sandbox.apply-for-teacher-training.service.gov.uk/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-cloudapps-qa = {
    website_name   = "Apply-Teacher-Training-Cloudapps-Sandbox"
    website_url    = "https://apply-sandbox.london.cloudapps.digital/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 1
  }
}
