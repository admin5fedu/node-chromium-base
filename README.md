# node-chromium-base

Image nền `ghcr.io/admin5fedu/node-chromium` = `node:22-alpine` + Chromium + font (Noto, Liberation, FreeFont).
Dùng cho stage `runner` của các app Next.js cần xuất PDF bằng puppeteer (khuôn `template-thanh-thanh-cong` và các app sinh từ nó).

```dockerfile
FROM ghcr.io/admin5fedu/node-chromium:22 AS runner
```

Đã có sẵn `PUPPETEER_SKIP_DOWNLOAD=1`, `PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser`.

## Vì sao

Mỗi app tự `apk add chromium` thì mỗi lần build sinh một lớp ~916 MB digest khác nhau → Docker không dùng chung được giữa các app (VPS 5fedu từng giữ ~10 bản, ~8 GB). Một image nền chung = lớp đó nằm trên đĩa một lần, build app cũng nhanh hơn.

## Tag

| Tag | Ý nghĩa |
|---|---|
| `22` | Tag trượt — app dùng tag này |
| `22-YYYYMMDD` | Tag cố định của từng lần dựng — để quay về bản cũ |

Workflow `build` chạy khi push `main`, ngày 1 hằng tháng (bản vá Chromium), hoặc bấm tay (Actions → build → Run workflow).
Repo public nên Actions không tính vào hạn mức phút; package GHCR public miễn phí.

## Trên VPS

Dokploy build không `--pull` → VPS giữ bản `:22` đã kéo. Cron root ngày 2 hằng tháng `docker pull ghcr.io/admin5fedu/node-chromium:22`; app nhận bản mới ở lần deploy kế tiếp.

Quay về bản cũ: trên VPS `docker pull ghcr.io/admin5fedu/node-chromium:22-<ngày> && docker tag ghcr.io/admin5fedu/node-chromium:22-<ngày> ghcr.io/admin5fedu/node-chromium:22` rồi deploy lại app.

## Luật

- Không đưa gì riêng của app vào đây (user, thư mục, env app).
- Gói hệ thống nặng mà nhiều app cùng cần → thêm vào đây, không cài ở từng app.
