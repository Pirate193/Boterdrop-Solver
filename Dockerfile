FROM python:3.10-slim

# 1. Install base system utilities and Xvfb for headless browser rendering
RUN apt-get update && apt-get install -y \
    xvfb \
    libasound2 \
    wget \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Set working directory
WORKDIR /app

# 3. Clone the Turnstile-Solver repository directly
RUN git clone https://github.com/najibyahya/Turnstile-Solver .

# 4. Install Python dependencies and OS-level browser dependencies
RUN pip install --no-cache-dir fastapi==0.95.2 uvicorn "camoufox[fetch]" loguru psutil playwright
RUN playwright install-deps

# 5. Fetch Camoufox and Playwright browser binaries
RUN python3 -m camoufox fetch
RUN playwright install

# 6. Generate config.json configured for standard port 8000
RUN echo '{\n\
    "headless": true,\n\
    "thread": 2,\n\
    "page_count": 1,\n\
    "proxy_support": false,\n\
    "proxy_file": "proxies.txt",\n\
    "host": "0.0.0.0",\n\
    "port": 8000,\n\
    "debug": false,\n\
    "cleanup_interval_minutes": 10\n\
}' > config.json

# 7. Expose standard API port
EXPOSE 8000

# 8. Start the API wrapped in virtual display (xvfb)
CMD ["xvfb-run", "-a", "python3", "api_server.py"]
