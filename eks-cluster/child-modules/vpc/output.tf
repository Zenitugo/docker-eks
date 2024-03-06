
# Output vpc id
output "vpc-id" {
    value              = aws_vpc.main-vpc.id
}

# Output public subnet ids
output "public-subnet-ids" {
    value              = aws_subnet.public-subnet.*.id
}


# Output private subnet ids

output "private-subnet-ids" {
    value              = aws_subnet.private-subnet.*.id 
}