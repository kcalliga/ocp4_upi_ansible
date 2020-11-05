#/bin/bash/
cp -rp def-vars-secret.template secrets.yml
cp -rp def-vars-main.template main.yml               
##User inputs for ansible playbook variables
echo -n "Enter forward dns zone (example: acme.com): "
read forward_dns_zone
sed -i "s/%%forward_dns_zone%%/$forward_dns_zone/g" main.yml
echo -n "Enter reverse dns zone (example: 100.168.192.in-addr.arpa): "
read reverse_dns_zone
sed -i "s/%%reverse_dns_zone%%/$reverse_dns_zone/g" main.yml
echo -n "Enter suppport server's IP address: " 
read support_server_ip
sed -i "s/%%support_server_ip%%/$support_server_ip/g" main.yml
echo -n "Enter suppport server's  fqdn (example: support.example.com): " 
read support_server_fqdn
sed -i "s/%%support_server_fqdn%%/$support_server_fqdn/g" main.yml
echo -n "Enter suppport server's short name (example: support): " 
read support_server_short_name
sed -i "s/%%support_server_short_name%%/$support_server_short_name/g" main.yml
echo -n "Enter internal ip subnet (example: 192.168.100.0/24): " 
read internal_ip_subnet
sed -i "s[%%internal_ip_subnet%%[$internal_ip_subnet[g" main.yml
echo -n "Enter top level domain name (example: acme.com): " 
read toplevel_domain
sed -i "s/%%toplevel_domain%%/$toplevel_domain/g" main.yml
echo -n "Enter cluster base domain name (example: acme.com): " 
read cluster_basedomain
sed -i "s/%%cluster_basedomain%%/$cluster_basedomain/g" main.yml
echo -n "Enter Openshift's cluster name: " 
read cluster_name
sed -i "s/%%cluster_name%%/$cluster_name/g" main.yml
echo -n "Enter Red Hat CoreOS Image URL (example: https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.5/4.5.6/): " 
read rhcos_mirror
sed -i "s[%%rhcos_mirror%%[$rhcos_mirror[g" main.yml
echo -n "Enter Red Hat CoreOS initramfs file name  (example: rhcos-installer-initramfs.x86_64.img): " 
read installer_initramfs_file
sed -i "s/%%installer_initramfs_file%%/$installer_initramfs_file/g" main.yml
echo -n "Enter installer kernel file name (example: rhcos-installer-kernel-x86_64): " 
read installer_kernel_file
sed -i "s/%%installer_kernel_file%%/$installer_kernel_file/g" main.yml
echo -n "Enter installer image file name (example: rhcos-metal.x86_64.raw.gz): " 
read installer_image_file
sed -i "s/%%installer_image_file%%/$installer_image_file/g" main.yml
echo -n "Enter netywork gateway IP (example: 192.168.100.1): " 
read gateway_ip
sed -i "s/%%gateway_ip%%/$gateway_ip/g" main.yml
echo -n "Enter URL for Openshift client tools(example: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.5/): " 
read oc_files_url
sed -i "s[%%oc_files_url%%[$oc_files_url[g" main.yml
echo -n "Enter Openshift client file name to be downloaded (example: openshift-client-linux.tar.gz): " 
read oc_client_url
sed -i "s/%%oc_client_url%%/$oc_client_url/g" main.yml
echo -n "Enter Openshift installer file name to be downloaded (example: openshift-install-linux.tar.gz): " 
read oc_install_file
sed -i "s/%%oc_install_file%%/$oc_install_file/g" main.yml
echo -n "Enter DHCP subnet IP (example: 192.168.100.0): " 
read dhcp_subnet
sed -i "s/%%dhcp_subnet%%/$dhcp_subnet/g" main.yml
echo -n "Enter DHCP starting IP (example: 192.168.100.1): " 
read dhcp_start_ip
sed -i "s/%%dhcp_start_ip%%/$dhcp_start_ip/g" main.yml
echo -n "Enter DHCP ending IP (example: 192.168.100.252): " 
read dhcp_end_ip
sed -i "s/%%dhcp_end_ip%%/$dhcp_end_ip/g" main.yml
echo -n "Enter DHCP netmask (example: 255.255.255.0): " 
read dhcp_netmask
sed -i "s/%%dhcp_netmask%%/$dhcp_netmask/g" main.yml
echo -n "Enter DHCP broadcast address (example: 192.168.100.255): " 
read dhcp_broadcast_address
sed -i "s/%%dhcp_broadcast_address%%/$dhcp_broadcast_address/g" main.yml
echo -n "Enter SSH public key (can be found in ~/.ssh/id_rsa.pub ): " 
read core_ssh_public_key
sed -i "s[%%core_ssh_public_key%%[$core_ssh_public_key[g" main.yml
echo -n "Enter cluster pull secret (can be retrieved from https://cloud.redhat.com/openshift/install/pull-secret): "
stty -echo
read cluster_pullsecret
sed -i "s[%%cluster_pullsecret%%[$cluster_pullsecret[g" secrets.yml
stty echo
echo
echo -n  "Enter ansible vault password: "
read -s vault_password
echo -n "Is it disconnected install?  "
read response
if [[ $response == "y" || $response == "Y" ]]; then
	echo -n "Enter registry CSR orgnization name: "
        read CSR_organization_name
        sed -i "s/#CSR_organization_name: %%CSR_organization_name%%/CSR_organization_name: $CSR_organization_name/g" main.yml
	echo -n "Enter registry CSR email address: "
        read CSR_email_address
        sed -i "s/#CSR_email_address: %%CSR_email_address%%/CSR_email_address: $CSR_email_address/g" main.yml
        echo -n "Enter registry CSR state (example: MD):  "
        read CSR_state
        sed -i "s/#CSR_state: %%CSR_state%%/CSR_state: $CSR_state/g" main.yml
        echo -n "Enter registry CSR locality (example: Baltimore):  "
        read CSR_locality
        sed -i "s/#CSR_locality: %%CSR_locality%%/CSR_locality: $CSR_locality/g" main.yml
        echo -n "Enter Openshift registry version (example: 4.3.0-x86_64):  "
        read ocp_release
        sed -i "s/#ocp_release: %%ocp_release%%/ocp_release: $ocp_release/g" main.yml
	sed -i "s[#CSR_country_name: US[CSR_country_name: US[g" main.yml
        sed -i "s[#CSR_organizational_unit_name: None[CSR_organizational_unit_name: None[g" main.yml
        sed -i "s[#local_docker_registry_url: docker-registry.{{ forward_dns_zone }}[local_docker_registry_url: docker-registry.{{ forward_dns_zone }}[g" main.yml
        sed -i "s[#local_registry: '{{ local_docker_registry_url }}:5000'[local_registry: '{{ local_docker_registry_url }}:5000' [g" main.yml
	sed -i "s[#local_repository: 'ocp4/openshift4'[local_repository: 'ocp4/openshift4'[g" main.yml      
	sed -i "s[#product_repo: 'openshift-release-dev'[product_repo: 'openshift-release-dev'[g" main.yml
	sed -i "s[#local_secret_json_filename: 'pull-secret.json'[local_secret_json_filename: 'pull-secret.json'[g" main.yml      
	sed -i "s[#release_name: 'ocp-release'[release_name: 'ocp-release'[g" main.yml
	echo -n "Enter registry username:  "
        read htpasswd_docker_user
        sed -i "s[#htpasswd_docker_user: %%htpasswd_docker_user%%[htpasswd_docker_user: $htpasswd_docker_user[g" secrets.yml
        echo -n "Enter registry password:  "
        read htpasswd_docker_password
        sed -i "s[#htpasswd_docker_password: %%htpasswd_docker_password%%[htpasswd_docker_password: $htpasswd_docker_password[g" secrets.yml
        echo $cluster_pullsecret > pull.json
        quay_io_token=`cat pull.json | python -m json.tool| grep -wns quay.io -C 1| grep auth| awk -F ':' '{ print $2 }'| awk -F ',' '{ print $1 }'|awk -F '"' ' { print $2 }'`
	sed -i "s[#quay_io_token: ''[quay_io_token: '$quay_io_token'[g" secrets.yml
        registry_connect_redhat_com_token=`cat pull.json | python -m json.tool| grep -wns registry.connect.redhat.com -C 1| grep auth| awk -F ':' '{ print $2 }'| awk -F ',' '{ print $1 }'|awk -F '"' ' { print $2 }'`
	sed -i "s[#registry_connect_redhat_com_token: ''[registry_connect_redhat_com_token: '$registry_connect_redhat_com_token'[g" secrets.yml
        cloud_openshift_com_token=`cat pull.json | python -m json.tool| grep -wns cloud.openshift.com -A1| grep auth| awk -F ':' '{ print $2 }'| awk -F ',' '{ print $1 }'|awk -F '"' ' { print $2 }'`
	sed -i "s[#cloud_openshift_com_token: ''[cloud_openshift_com_token: '$cloud_openshift_com_token'[g" secrets.yml
        registry_redhat_io_token=`cat pull.json | python -m json.tool| grep -wns registry.redhat.io -C 1| grep auth| awk -F ':' '{ print $2 }'| awk -F ',' '{ print $1 }'|awk -F '"' ' { print $2 }'`
        sed -i "s[#registry_redhat_io_token: ''[registry_redhat_io_token: '$registry_redhat_io_token'[g" secrets.yml
        sed -i "s[#email: email@domain.com[email: '$CSR_email_address'[g" secrets.yml
        rm -rf pull.json
else 
	echo "Skipping configuration of disconnected variables"
fi
echo $vault_password > vault-secret.txt
ansible-vault encrypt secrets.yml --vault-password-file vault-secret.txt
rm -rf vault-secret.txt
mv secrets.yml /home/ansible/42_deployment/roles/default_vars/vars/.
mv main.yml /home/ansible/42_deployment/roles/default_vars/vars/.
