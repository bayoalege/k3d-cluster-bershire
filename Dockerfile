# Use a lighter version of Nginx
FROM nginx:1.24-alpine

# Replace the default index.html file with my file
COPY index.html /usr/share/nginx/html/