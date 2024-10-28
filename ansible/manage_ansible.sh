


ssh_file="C:\\keys aws\\ec2key.pem"

app_0=$(terraform output -raw app_instance_0_public_dns)
app_1=$(terraform output -raw app_instance_1_public_dns)
db_host=$(terraform output -raw db_instance_public_dns)


cat <<EOF > "C:\\keys aws\\hosts"
[foo]
${app_0} ansible_ssh_private_key_file="${ssh_file}"
${app_1} ansible_ssh_private_key_file="${ssh_file}"

[foo_db]
${db_host} ansible_ssh_private_key_file="${ssh_file}"
EOF

#
db_ip=$(terraform output -raw db_instance_private_ip)


ansible-playbook /home/ubuntu/ansible/main.yml --extra-vars "db_ip=${db_ip}" -i "C:\\keys aws\\hosts"

if terraform output -json | jq -e '.lb_dns' > /dev/null; then
  lb_dns=$(terraform output -raw lb_dns)
  echo "The app is now being hosted on the following URL: http://${lb_dns}/"
else
  echo "No load balancer found. The app servers are accessible at the following addresses:"
  echo "App Server 1: http://${app_0}"
  echo "App Server 2: http://${app_1}"
  echo "Database Server: ${db_host}"
fi
