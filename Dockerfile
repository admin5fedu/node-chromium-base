# Image nền dùng chung: Node 22 Alpine + Chromium + font tiếng Việt.
#
# Vì sao có image này: các app sinh từ `template-thanh-thanh-cong` xuất PDF bằng
# puppeteer (`lib/pdf/render-html-to-pdf.ts`), cần Chromium hệ thống. Trước đây
# mỗi app tự `apk add chromium …` trong stage `runner` → mỗi lần build sinh một
# lớp 916 MB digest mới, Docker không gộp được giữa các app → VPS 5fedu giữ
# ~10 bản Chromium (~8 GB). Giờ các app `FROM ghcr.io/admin5fedu/node-chromium:22`
# nên lớp này chỉ nằm trên đĩa một lần.
#
# KHÔNG đưa gì riêng của app vào đây (user, thư mục, env app).
FROM node:22-alpine

# `font-noto` là BẮT BUỘC — thiếu nó tiếng Việt có dấu render thành ô vuông trong PDF.
# `ttf-liberation` là lưới an toàn: tài liệu chốt Times New Roman, container không có TNR;
# Tinos nhúng base64 gánh chính, Liberation Serif (cùng metric) đỡ nếu font nhúng không nạp.
# `libc6-compat` (gcompat) cho Chromium — chỉ ở image chạy, KHÔNG dùng cho stage `npm ci`
# (làm npm chọn nhầm binary glibc của @next/swc, sharp).
RUN apk add --no-cache \
  libc6-compat \
  chromium \
  nss \
  freetype \
  harfbuzz \
  ca-certificates \
  ttf-freefont \
  font-noto \
  ttf-liberation

ENV PUPPETEER_SKIP_DOWNLOAD=1
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

LABEL org.opencontainers.image.source="https://github.com/admin5fedu/node-chromium-base" \
  org.opencontainers.image.description="Node 22 Alpine + Chromium + font tiếng Việt — nền chung cho các app 5F" \
  org.opencontainers.image.licenses="MIT"
