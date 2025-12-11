# Dockerfile for a static site
FROM nginx:alpine
LABEL maintainer="mdsharuf"

# Remove default nginx content, copy site files
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html

# Copy images folder if it exists
COPY images /usr/share/nginx/html/images

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

