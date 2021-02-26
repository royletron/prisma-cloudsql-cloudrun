## Setting up Google Cloud Env

So you will need a project, with billing account, a container registry, cloudsql instance and the cloudrun service

```bash
PROJECT=test-project
BILLING=billing-account
REGION=europe-west1
DB_INSTANCE=test-instance
DB_CONNECTION=${PROJECT}:${REGION}:${DB_INSTANCE}
DB_NAME=test-database
DB_USER=postgres
DB_PASSWORD=test-password

gcloud projects create ${PROJECT}
gcloud alpha billing projects link $PROJECT \
--billing-account=$BILLING
for SERVICE in containerregistry cloudrun sqladmin
do
  gcloud service enable ${SERVICE}.googleapis.com \
  --project=${PROJECT}
done

gcloud sql instances create ${DB_INSTANCE} \
--cpu=1 --memory=4096MiB \
--database-version=POSTGRES_13 \
--project=${PROJECT}
gcloud sql users set-password ${DB_USER} \
--host="%" \
--instance=${DB_INSTANCE} \
--password=${DB_PASSWORD} \
--project=${PROJECT}
gcloud sql databases create ${DB_NAME} \
--instance=${DB_INSTANCE} \
--project=${PROJECT}
```

This should give you the lot!

## Run Locally

To do this you need to first start the `CloudSQL Proxy` on your machine:

```bash
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x ./cloud_sql_proxy
sudo mkdir /tmp/cloudsql
sudo chown -R $(whoami) /tmp/cloudsql
./cloud_sql_proxy -instances=${DB_CONNECTION} -dir=/tmp/cloudsql
```

And then you can either run 'natively' (use vars from top script)

```bash
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@0.0.0.0/${DB_NAME}?host=/tmp/cloudsql/${DB_CONNECTION}
npx prisma migrate deploy --preview-feature
npm start
```

Or go via docker ...

## Docker Image

To build the image and push to your new registry (use vars from top script)

```bash
SERVICE=test-service
docker build -f Dockerfile -t gcr.io/${PROJECT}/${SERVICE}:latest .
docker push gcr.io/${PROJECT}/${SERVICE}:latest
```

You can also run this locally if that's helpful (see how to start the `CloudSQL Proxy` above and make sure it's running. Use other vars from top script)

```bash
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@0.0.0.0/${DB_NAME}?host=/cloudsql/${DB_CONNECTION}
docker run -e DATABASE_URL=$DATABASE_URL -e DEBUG="*" -p 3000:3000 -m=512m --cpus=1 -v /tmp/cloudsql:/cloudsql --rm gcr.io/${PROJECT}/${SERVICE}:latest
```

## Start CloudRun

Then we can combine all of this to start running in CloudRun (use vars from top script)

```bash
SERVICE=test-service # needs to be the same as docker image.
gcloud beta run deploy ${SERVICE} --platform managed --image=gcr.io/${PROJECT}/${SERVICE}:latest --set-env-vars="DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@localhost/${DB_NAME}?host=/cloudsql/${DB_CONNECTION}&pool_timeout=0&connect_timeout=5,DEBUG=*" --add-cloudsql-instances=${DB_INSTANCE} --region=${REGION} --project=${PROJECT}
```

If all goes well you should be able to see the logs in your CloudRun console.