//Project auth parameters:
GOOGLE_SA_KEY             = "C:/Users/Rocca/Desktop/epam-gcp-tf-3a080f9b9983.json"
GOOGLE_PROJ_ID            = "epam-gcp-tf"

//Regional parameters:
REGION                    = "us-central1"
ZONE                      = "us-central1-a"

//Network:
VPC_NAME                  = "pmc-vpc"
SUBNET_NAME               = "pmc-subnet"
SUBNET_IP_RANGE           = "172.16.20.0/24"
CLOUD_ROUTER_NAME         = "pmc-cloud-router"
CLOUD_NAT_NAME            = "pmc-nat-gateway"

//Database:
DB_NAME                   = "php_mysql_crud"
DB_USER_NAME              = "dbuser"
DB_USER_PASSWORD          = "p1ssw0rd"
DB_INSTANCE_NAME          = "pmc-db-mysql"
DB_INSTANCE_VERSION       = "MYSQL_8_0"
DB_INSTANCE_TYPE          = "db-f1-micro"

//Bucket Storage:
TF_BUCKET_NAME            = "pmc-tfstate-bucket"
TF_BUCKET_LOCATION        = "US"
TF_BUCKET_CLASS           = "STANDARD"
APP_BUCKET_NAME           = "php-mysql-crud-app-bucket"
APP_BUCKET_LOCATION       = "US"
APP_BUCKET_CLASS          = "STANDARD"

//IAM:
SERVICE_ACCOUNT_ID        = "pmc-service-account"
SERVICE_ACCOUNT_NAME      = "pmc-service-account"
IAM_ROLES                 = ["roles/storage.objectViewer"]

//Instance Template, Managed Instance Group, Load Balancer:
INSTANCE_TEMPLATE_NAME    = "pmc-instance-template"
INSTANCE_TYPE             = "e2-micro"
INSTANCE_GROUP_NAME       = "pmc-instance-group"


