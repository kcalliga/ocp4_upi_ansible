#/bin/bash/

## Configure Ansible variables
echo -n "Do you want to configure ansible variables? "
read response
if [[ $response == "y" || $response == "Y" ]]; then
	./config-vars.sh
else
	echo "Using existing ansible variables....."
fi

## Configure ansible inventory from *.info files
./inventory-config.sh
mv inventory.template inventory

## Run the playbooks based on disconnected install or otherwise
echo -n "Is it disconnected install?  "
read dis_response
if [[ $dis_response == "y" || $dis_response == "Y" ]]; then
	ansible-playbook -i inventory 42_provision_support_upi.yml -e disconnected=true --ask-vault-pass
else
       ansible-playbook -i inventory 42_provision_support_upi.yml -e disconnected=false --ask-vault-pass
fi

## Move install-config.yaml file to installation directory
rm -rf /home/ansible/openshift_install
mkdir /home/ansible/openshift_install
cp -rp /home/ansible/install-config.yaml /home/ansible/openshift_install/

## Create Openshift Manifest files
openshift-install create manifests --dir=/home/ansible/openshift_install

## Create Openshift ignition files: bootstrap, master and worker
echo -n "Do you have compute nodes in your cluster?   "
read response
if [[ $response == "y" || $response == "Y" ]]; then
	sed -i "s/mastersSchedulable: true/mastersSchedulable: false/g" /home/ansible/openshift_install/manifests/cluster-scheduler-02-config.yml 
else
	echo -n "Master nodes will be schedulable"
fi
openshift-install create ignition-configs --dir=/home/ansible/openshift_install

if [[ $dis_response == "y" || $dis_response == "Y" ]]; then
        cd /home/ansible 
	/home/ansible/mirror-sync.sh
        cd -
else
	echo
fi


## Move the ignition files to apache http folder (/var/www/html)
sudo cp -rp /home/ansible/openshift_install/*.ign /var/www/html/
sudo chown root:root /var/www/html/*.ign
sudo chmod 644 /var/www/html/*.ign

## Printing subsequent installation instructions
echo ""
echo ""
echo ""
echo "Now you can START PXE BOOTING the BOOTSTRAP sever followed by MASTER nodes and finally COMPUTE nodes"
sleep 5
echo "*****************************************************************************************************"
echo "*****************************************************************************************************"
echo "--->AFTER SUCCESSFULLY BOOTING the master nodes RUN the command 'openshift-install wait-for bootstrap-complete --dir=/home/ansible/openshift_install' command<---" 
echo "*****************************************************************************************************"
echo "*****************************************************************************************************"
