This install has been tested with RHEL 7.7 minimal install being used on the mirror registry and support server (these can be the same server in some cases).  The support server (typically on the restricted network) handles the DHCP, PXE, HTTPD, HAPROXY, and DNS functions needed to pxe boot the bootstrap, masters, and nodes.

After cloning this repository, edit the ./roles/default_vars/vars/main.yml file.  An example with comments is included and called main.yml.example
Also, edit the ./roles/default_vars/vars/secrets.yml file.  I use Ansible vault to encrypt this.  An example with comments is included and called secrets.yml.example

There are 2 playbooks and a sample inventory file in the root of this repo.  The first playbook (deploy_mirror_registy.yml) is run from a server with access to the Internet.  In my test case, I used the same support server but it will most likely be 2 different servers (one with access to the internet and one on the restricted network)

Populate the inventory file following the example.  Use the internal fqdns.  Follow the same formatting as the example for each of the MAC addresses as well.

deploy_mirror_registry.yml (this needs to be run somewhere with access to the internet)

	This playbook uses the instructions located at https://docs.openshift.com/container-platform/4.2/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations

	Two roles are run. deploy_registry and mirror_registry.  The deploy_registry role creates everything under /opt/registry including htpasswd authentication and self-signed cert.  The actual mirroring of the oc images doesn't occur until you run the mirror-registry.sh script that is described below.

Run the deploy_mirror_registry.yml playbook from the GIT repo's root directory.  If you use an encrypted secrets.yml file, run as follows:
	ansible-playbook -i inventory deploy_mirror_registry.yml --ask-vault-pass --ask-become-pass

This playbook will generate 2 artifacts in your home directory (or another directory you used in your vars file).  The artifacts are called mirror-registry.sh and the pull-secret.json file.

At this point, run the following comman from your artifact directory

	./mirror-registry.sh (this also needs to run with access to the internet)

mirror-registry.sh will populate the local registry with the images that are needed based on the version of Openshift you picked.

Another artifact that is generated from this command is the customized openshift-install script which will be put in your artifact directory.

I find it useful to copy the openshift-install script to the the /opt/registry directory.  Also make sure you public key and private key (used to SSH to nodes as core user) are in this repo.

Tar up/Gzip everything under the /opt/registry directory and copy to somewhere on your restricted environment.  Also, pull in the docker.io/library/registry:2 image so that the local-registry will run on the restricted network.  You may also find it handy to bring over this Git repo and all of the CoreOS images and oc-client binaries.  The COREOS images and oc-clients should be copied to a web server on your restricted network

Edit the ./roles/default_vars/vars/main.yml file to point to the correct url (on your restricted network) of the COREOS images and oc-client

On the server that is to be used on the restricted network, untar the /opt/registry directory and start the podman docker registry

podman run --name mirror-registry -p <local_registry_host_port>:5000 \ 
     -v /opt/registry/data:/var/lib/registry:z \
     -v /opt/registry/auth:/auth:z \
     -e "REGISTRY_AUTH=htpasswd" \
     -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
     -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
     -v /opt/registry/certs:/certs:z \
     -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
     -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
     -d docker.io/library/registry:2

You may need to open up port 5000 in firewalld so that the bootstrap server (and other oc masters/clients) will provision themselves.

From this server, run the 42_provision_support_upi.yml playbook

	ansible-playbook -i inventory 42_provision_support_upi.yml --ask-vault-pass --ask-become-pass

This playbook will run the following roles (most of the steps mentioned on https://docs.openshift.com/container-platform/4.2/installing/installing_bare_metal/installing-bare-metal.html):

    - role: create_dhcp_server (creates the dhcpd.conf config and populates mac address/ip assignments)
    - role: create_pxe_server (populates the COREOS files and MAC address pointers in the pxelinux.cfg directory)
    - role: create_haproxy_server (Creates listeners on 6443, 22623, and 443)
    - role: create_http_server (hosts the ignition files and metal install images)
    - role: pull_oc_images (pulls the COREOS images and oc-client from accesible webserver)
    - role: create_install_config (creates the install-config-yaml file in your artifact directory)

Once this playbook is run the install-config.yaml file will be populated to your artifact directory.

From here, perform the following steps:

1.  Copy the customized openshift-install binary to the artifact directory.
2.  make a new directory here to be used for the openshift install manifests, auth, and ign files.  These will be generated when you run the openshift-install commands next.
3.  Copy the install-config.yaml to this directory.  Be sure to copy the file as it is consumed (and deleted) by the installer.
4.  Run the openshift-install create manifests.
	./openshift install create manifests --dir=<artifact dir>/<install directory> 
5.  Modify the manifests/cluster-scheduler-02-config.yml Kubernetes manifest file to prevent Pods from being scheduled on the control plane machines:

    Open the manifests/cluster-scheduler-02-config.yml file.

    Locate the mastersSchedulable parameter and set its value to False.
6.  Run the openshift-install create ignition-configs
	./openshift-install create ignition-configs --dir=<artifact dir>/<install directory>
7.  Copy the ign files (master, bootstrap, and worker) to the root of the webserver (/var/www/html).
8.  Run ./openshift-install --dir=<artifact dir>/<install directory> wait-for bootstrap-complete --log-level=info
9.  This command should exit once the API is available.  You can remove the bootstrap server from your haproxy config when this is finished.
10.  Follow the remaining steps (section called Logging in to the cluster) on the https://docs.openshift.com/container-platform/4.2/installing/installing_bare_metal/installing-bare-metal.html page.

