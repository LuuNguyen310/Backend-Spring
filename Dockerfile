# Dùng bản Postgres 16 (hoặc version bạn thích)
FROM postgres:16

# Copy file script vào thư mục khởi tạo
# Postgres sẽ tự động chạy file này KHI DATABASE TRỐNG
COPY postgreSQL-KitchenControl.sql /docker-entrypoint-initdb.d/
