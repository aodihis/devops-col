.PHONY: jenkins

build-jenkins:
	docker build -t myjenkins-blueocean:2.492.2-1 .

run-jb:
	docker run --name jenkins-blueocean --detach \
	  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
	  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
	  --volume jenkins-data:/var/jenkins_home \
	  --volume jenkins-docker-certs:/certs/client:ro \
	  --volume "$(HOMEDRIVE)$(HOMEPATH)":/home \
	  --restart=on-failure \
	  --env JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" \
	  --publish 49000:8080 --publish 50000:50000 myjenkins-blueocean:2.492.2-1


.PHONY: dind

run-jd:
	docker run --name jenkins-docker --detach \
	  --privileged --network jenkins --network-alias docker \
	  --env DOCKER_TLS_CERTDIR=/certs \
	  --volume jenkins-docker-certs:/certs/client \
	  --volume jenkins-data:/var/jenkins_home \
	  --restart always \
	  --publish 3000:3000 --publish 5050:5050 --publish 2376:2376 \
	  docker:dind

run-prometheus:
	docker run -d --name prometheus -p 9090:9090 prom/prometheus

run-grafana:
	docker run -d --name grafana -p 3030:3030 -e "GF_SERVER_HTTP_PORT=3030" grafana/grafana

start-jenkins:
	docker start jenkins-blueocean

start-jb:
	docker start jenkins-docker

start-prometheus:
	docker start prometheus

start-grafana:
	docker start grafana