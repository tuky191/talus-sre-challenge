# Solution

## Brief design description

Design consists of a regional GKE private cluster which uses NAT for internet connectivity. The cluster has currently 4 nodepools. One for each AZ of backend service, monitoring and data. Each can be scaled independently by updating the params.json.
Backend pods are separated into READ and WRITE deployments. Each AZ deploys both groups, adding its suffix to the deployment.

There are 2 headless services, backend-read and backend-write. They serve as backend for ingress-rest ingress. There is a separate ingress for monitoring.
Ingress-rest forwards the GET requests to READ and POST requests to WRITE pods. Ingress-monitoring forwards requests to grafana.

Nodepools are deployed with enabled autoscaling. There is also HPA for the backend service pods based on CPU utilization.

## Architecture Diagram

![Architecture Diagram](./img/Infrastructure-diagram.png)

## High Availability

Regional cluster and workload spread over multiple availability zones ensures that service remains up, even when all but one AZ remains operational. See [diagram](./img/Infrastructure-diagram.png) for details.

## Fault Tolerance

Currently there there are 2 READ and 2 WRITE pods. We can lose N-1 AZs and still be able to serve requests.

```bash
    ➜ kubectl get pods -n chains
    NAME                                   READY   STATUS      RESTARTS        AGE
    backend-app-read-a-698ccb8c5c-wcvdc    1/1     Running     0               6m13s
    backend-app-read-b-645b96c8d7-xz7cp    1/1     Running     0               38s
    backend-app-write-a-6b585f6f8c-mg8xn   1/1     Running     0               6m13s
    backend-app-write-b-7c7fcb79b5-pw85l   1/1     Running     0               6m13s
```

## Dockerization

There is a docker-compose located in infra/docker. It deploys the core services(backend flaskApp and redis), monitoring(grafana, prometheus, loki, promtail) and logging ELK stack with filebeat. [Traefik](http://localhost:8080/dashboard/#/) is used to loadbalance the web backend service. Redis serves as a key/value
store for the backend services.

To deploy, navigate to the docker folder, first run the build command, then compose up.

```bash
    ➜ cd infra/docker
    ➜ docker compose build
    <omitted>
    ➜ docker compose up -d
     ✔ Network docker_default   Created
     ✔ Container loki           Started
     ✔ Container docker-web-3   Started
     ✔ Container docker-web-1   Started
     ✔ Container docker-web-2   Started
     ✔ Container elasticsearch  Started
     ✔ Container redis          Started
     ✔ Container kibana         Started
     ✔ Container logstash       Started
     ✔ Container promtail       Started
     ✔ Container traefik        Started
     ✔ Container filebeat       Started
     ✔ Container prometheus     Started
     ✔ Container grafana        Started
```

### ELK

For more comprehensive log processing, [Kibana](http://localhost:5601) can be used to visualize data, create Ingest Pipelines, etc. As show in picture of [discover](./img/kibana.png) view. Filebeat and Logstash are used to forward data to Elastic Search.

### Grafana

Alternatively Grafana, together with Prometheus, Loki and Promtail can be used to achieve similar goal. There are 2 preconfigured [dashboards](./img/grafana-dashboards.png).

Centralized logs from the backend [service](./img/grafana-logs.png) can be viewed thru Logs / App dashboard.
Traffic statistics captured from traefik loadbalancer are available from Traefik [chart](./img/traefik.png)

[hey](https://github.com/rakyll/hey) can be used to simulate GET and POST requests.

```bash
    hey -n 100000 -c 10 http://localhost/items
    hey -n 10000 -c 10 -m POST -H "Content-Type: application/json" -d '{"name": "Sample Item"}' http://localhost/items
```

## Infrastructure Provisioning with Terraform

### Setup

Terraform configuration is located in infra/terraform. Whole deployment is automated, driven by github actions [Build Image and Deploy Infra](../.github/workflows/build_and_deploy.yaml). This github action deploys either on manual trigger, or after creation of a new tag.

There are few pre requisites for successfull deployment.

- [GCP](https://console.cloud.google.com/) account
- [Terraform Cloud](https://app.terraform.io/public/signup/account) account
- Fork of [repository](https://github.com/tuky191/talus-sre-challenge)
- [Cloudflare](https://dash.cloudflare.com/sign-up)

#### GCP

- Create new Project
- Create credentials for the terraform cloud user. Navigate to [IAM & Admin/Service](./img/gcp-1.png) Accounts. Create new Service account e.g. [terraform](./img/gcp-2.png), assign it [Owner](./img/gcp-3.png) priviledges.
  Navigate again to Service Accounts and select your newly created [account](./img/gcp-4.png). From there go to [KEYS](./img/gcp-5.png) and create new private key. Make sure to select [JSON](./img/gcp-6.png)
  Download the key to your local. **Important** Use following command to base64 encode it. **Important**

  ```bash
    cat gcp-credential.json | tr -s '\n' ' ' | base64
  ```

- **Important** Enable APIs for [GKE](https://console.cloud.google.com/marketplace/product/google/container.googleapis.com) and [Cloud Resource Manager](https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com) **Important**

#### Terraform Clound

- Create new free [account](https://app.terraform.io/public/signup/account)
- Navigate to your [profile](./img/terraform-1.png)
- Create Terraform API token

#### Cloudflare

- Create new free [Cloudflare](https://dash.cloudflare.com/sign-up) account
- Buy or use a domain you already own
- [Point](./img/cloudflare.png) backend.your-domain and grafana.your-domain to your LoadBalancer IP. You can obtain it from the [Ingress view](./img/gcp-7.png).
- Cloudflare pro

#### Github

- Navigate to your profile / Developer settings
- Select Personal access tokens / Tokens (classic)
- Generate new [token](./img/github-1.png)
- Go back to your forked repo and add following repository [secrets](./img/github-2.png) and [variables](./img/gcp-3.png)

| Secret Name            | Content                        |
| ---------------------- | ------------------------------ |
| GOOGLE_CREDENTIALS     | base64 encoded gcp credentials |
| GRAFANA_ADMIN_PASSWORD | Admin password for grafana     |
| PAT_TOKEN              | Token for ghcr                 |
| TERRAFORM_CLOUD_TOKEN  | Terraform cloud token          |

| Variable Name               | Content                                                         |
| --------------------------- | --------------------------------------------------------------- |
| TERRAFORM_DOMAIN            | domain name for accessing backend and grafana from the internet |
| TERRAFORM_GOOGLE_PROJECT    | Name of the GCP project e.g. talus-challenge                    |
| TERRAFORM_GOOGLE_REGION     | Region where GCP deploys resources, e.g. us-east5               |
| TERRAFORM_ORGANIZATION_NAME | Name of terraform organization (created by github action)       |
| TERRAFORM_WORKSPACE_NAME    | Name of terraform workspace (created by github action)          |

- Enable Github actions in the Forked repo
- Run [Build Image and Deploy Infra](./img/github-4.png)

That's it. From now on everything is setup to happen automatically. Github action will create new terraform organization, workspace and variables. Terraform will deploy all resources to the GCP.
On occasion, in case something fails, you can redeploy by using the **_Deploy Infra_** github action.
