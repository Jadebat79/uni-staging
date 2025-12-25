# You need the Hosted Zone ID. You can fetch it via data source or variable.
data "aws_route53_zone" "main" {
  name = "teamcanvas.site." # Your root domain
}

resource "aws_route53_record" "staging_wildcard" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.staging.teamcanvas.site"  # The wildcard for all staging subdomains
  type    = "A"
  ttl     = "300"
  
  # This implies: "Look at the EIP resource and put its IP address here"
  records = [aws_eip.app_eip.public_ip] 
}