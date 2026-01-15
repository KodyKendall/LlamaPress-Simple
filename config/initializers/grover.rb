# frozen_string_literal: true

Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "10mm",
      bottom: "10mm",
      left: "10mm",
      right: "10mm"
    },
    prefer_css_page_size: true,
    emulate_media: "screen",
    cache: false,
    timeout: 0, # Timeout in ms. A value of `0` means 'no timeout'
    launch_args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"],
    executable_path: "/usr/bin/chromium"
  }
end
