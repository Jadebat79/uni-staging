# You need the Hosted Zone ID. You can fetch it via data source or variable.
data "aws_route53_zone" "main" {
  name = "teamcanvas.site." # Your root domain
}

# resource "aws_route53_record" "dozzle" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "logs.staging"  # The wildcard for all staging subdomains
#   type    = "A"
#   ttl     = "300"
  
#   # This implies: "Look at the EIP resource and put its IP address here"
#   records = [aws_eip.lb.public_ip] 
# }

# resource "aws_route53_record" "backend" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "gpc-api.staging"  # The wildcard for all staging subdomains
#   type    = "A"
#   ttl     = "300"
  
#   # This implies: "Look at the EIP resource and put its IP address here"
#   records = [aws_eip.lb.public_ip] 
# }

# resource "aws_route53_record" "backend" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "gpc-api.staging"  # The wildcard for all staging subdomains
#   type    = "A"
#   ttl     = "300"

#   # This implies: "Look at the EIP resource and put its IP address here"