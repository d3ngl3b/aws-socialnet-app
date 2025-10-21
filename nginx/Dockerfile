# Official Nginx image
FROM nginx:alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf