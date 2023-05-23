# cwcloud-wordpress-email

This is a wordpress extension for using the [cwcloud](https://cloud.comwork.io) email API:

```shell
curl -X 'POST' \
  'https://cloud-api.comwork.io/v1/email' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "from": "cloud@provider.com",
  "to": "recipient@provider.com",
  "bcc": "bcc@provider.com",
  "subject": "Subject",
  "content": "Content"
}'
```

There is an environment variable `CWCLOUD_API_TOKEN` to set on your wordpress instance.
