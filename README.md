## Take-Home Coding Assignment: Scalable Web Service with Monitoring and Fault Tolerance

### Objective

In this assignment, you will design and implement a scalable web service, set up deployment automation, and configure comprehensive monitoring and fault tolerance mechanisms. You will use Docker, Kubernetes (K3s), and a variety of monitoring and logging tools to achieve these goals.

### Requirements

1. **Service**:
    - **Web Service**: You are given a simple RESTful web service that performs CRUD operations on an in-memory datastore, in python.
    - **API Endpoints**:
        - `POST /items`: Create a new item.
        - `GET /items`: List all items
2. **Dockerization**:
    - Create a `Dockerfile` to containerize the web service.
    - Write a `docker-compose.yml` file to define the service and any additional required services (e.g., a mock database if needed).
3. **Infrastructure Provisioning with Terraform**:
    - Use Terraform to provision the following infrastructure on a cloud provider of your choice (e.g., AWS, Azure, Google Cloud):
        - **Compute Instances**: Deploy instances to host your web service containers.
        - **Load Balancer**: Set up a load balancer to distribute traffic to the web service instances.
        - **Auto-scaling Group**: Implement an auto-scaling group to handle scaling based on CPU utilization or other metrics.
        - **Networking**: Configure virtual private cloud (VPC), subnets, and security groups to ensure proper network segmentation and security.
    - Provide Terraform modules and configuration files to manage and provision the infrastructure.
4. **Monitoring and Logging**:
    - Set up monitoring using Prometheus and Grafana or another monitoring tool. Track metrics such as:
        - HTTP request rates.
        - Latency (response times).
        - Error rates.
        - Resource usage (CPU, memory).
    - Implement centralized logging using a tool like the ELK stack (Elasticsearch, Logstash, Kibana) or an alternative solution.
    - Ensure that logs from the web service are aggregated and easily searchable.
5. **Fault Tolerance**:
    - Implement simple health checks and liveness/readiness probes for your web service.
    - Ensure that the system can handle failure scenarios such as instance crashes or network issues without significant downtime.
6. **Documentation**:
    - Provide a `README.md` file with clear instructions on:
        - How to build and run the Docker container.
        - How to deploy the infrastructure using Terraform.
        - How to set up monitoring and logging.
        - How to test and validate the service and its fault tolerance mechanisms.

### Deliverables

1. **Code Repository**:
    - A GitHub repository (or similar) with:
        - Dockerfile for the web service.
        - `docker-compose.yml` file.
        - Terraform configuration files and modules for provisioning the infrastructure.
        - Configuration files for monitoring and logging tools.
2. **Documentation**:
    - A `README.md` file with detailed setup and usage instructions, as outlined in the requirements.
3. **Optional Enhancements** (for extra credit):
    - Implement a CI/CD pipeline using GitHub Actions, Jenkins, or another CI/CD tool.
    - Add automated tests for the web service (e.g., unit tests, integration tests).
    - Include security configurations such as network policies or role-based access controls (RBAC).

### Evaluation Criteria

- **Functionality**: The web service should meet all the API endpoint requirements and be fully operational.
- **Dockerization**: The Docker setup should be correct and efficient.
- **Terraform Infrastructure**: The Terraform configuration should be complete, correctly provision infrastructure, and be able to scale as required.
- **Monitoring and Logging**: Monitoring and logging should be well-configured, providing valuable insights into system performance and health.
- **Documentation**: The documentation should be thorough, making it easy to build, deploy, and monitor the system.
