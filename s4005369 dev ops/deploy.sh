
ansible_installed=0
terraform_installed=0
ssh_file="private.key"  


if [ "$(which ansible)" != "" ]; then ansible_installed=1; fi
if [ "$(which terraform)" != "" ]; then terraform_installed=1; fi

#
if [ $terraform_installed -eq 0 ]; then 
  echo "Terraform needs to be installed locally"
  exit 1
elif [ $ansible_installed -eq 0 ]; then
  echo "Ansible needs to be installed locally"
  exit 1
fi

echo "${TF_SSH_KEY}" > $ssh_file
chmod 600 $ssh_file


cd terraform/ec2/

# Initialize and apply Terraform
echo "Applying Terraform configuration..."
terraform init
terraform apply -auto-approve

# Extract DNS of app servers and database from Terraform outputs
app_1="$(terraform output -raw public_appdns_1) ssh_private_key_file=$ssh_file"
app_2="$(terraform output -raw public_appdns_2) ssh_private_key_file=$ssh_file"
db_host="$(terraform output -raw public_dbdns) ssh_private_key_file=$ssh_file"

# Update the Ansible inventory (hosts file) with the DNS names
cd ../../
sed -i "1s|.*|[foo]|" hosts  # Set app server group
sed -i "2s|.*|$app_1|" hosts  # First app server
sed -i "3s|.*|$app_2|" hosts  # Second app server
sed -i "5s|.*|[foo_db]|" hosts  # Set database group
sed -i "6s|.*|$db_host|" hosts  # Database DNS

# Retrieve private IP of the database from Terraform output
db_ip=$(terraform output -raw private_db_ip)

# Run Ansible playbook with database IP passed as an extra variable
echo "Deploying via Ansible..."
ansible-playbook ansible/main.yml --extra-vars "db_ip=$db_ip"

# Clean up the SSH private key
rm $ssh_file

# Print the URL for the app (Load Balancer DNS)
echo "The app is now being hosted on the following URL: $(terraform output -raw lb_dns)"
