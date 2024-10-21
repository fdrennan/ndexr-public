FROM nginx:1.24.0

# Copy local configuration files and content to the container
COPY ./config/nginx /etc/nginx
COPY ./src/html /usr/share/nginx/html


# Optionally set more restrictive permissions for other sensitive files
# RUN chmod -R 644 /etc/qscicerts/*.cer \
#  && chmod 644 /etc/qscicerts/*.csr \
#  && chmod 444 /etc/qscicerts/*.key

# Ensure proper permissions for Nginx configuration files
RUN chown -R nginx:nginx /etc/nginx \
 && chmod -R 644 /etc/nginx/*.conf \
 && chmod 600 /etc/nginx/*_params \
 && chown -R nginx:nginx /usr/share/nginx/html \
 && find /usr/share/nginx/html -type d -exec chmod 755 {} \; \
 && find /usr/share/nginx/html -type f -exec chmod 644 {} \;

# Validate Nginx configuration files
RUN #nginx -t
# Expose ports for HTTP and HTTPS
EXPOSE 80 443

# Start Nginx when the container has provisioned.
CMD ["nginx", "-g", "daemon off;"]
