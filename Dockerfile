FROM nginx:alpine

COPY users.json /usr/share/nginx/html/users.json
COPY posts.json /usr/share/nginx/html/posts.json
COPY products.json /usr/share/nginx/html/products.json