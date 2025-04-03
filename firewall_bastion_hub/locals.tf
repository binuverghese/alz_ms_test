

locals {
  forwarding_rulesets = [
    {
      outbound_endpoint_name = "example-outbound-endpoint"
      name                   = "example-ruleset"
      # Add other fields required in the ruleset
    },
    # Add more rulesets as needed
  ]
}
locals {
  forwarding_rules = [
    {
      outbound_endpoint_name = "example-outbound-endpoint"
      ruleset_name           = "example-ruleset"
      rule_name              = "example-rule"
      domain_name            = "example.com"
      enabled                = true
      metadata               = {}
      destination_ip_addresses = {
        "10.0.0.1" = 53
      }
    },
    # Add more forwarding rules as needed
  ]
}
locals {
  location = "Canada Central"  # Replace with your preferred location
}
