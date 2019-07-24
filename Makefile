init:
	helm init --client-only
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add stable https://kubernetes-charts.storage.googleapis.com

build: clean init
	jx step helm build
	helm lint .

clean: 
	rm -rf charts
	rm -rf requirements.lock
