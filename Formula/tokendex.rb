class Tokendex < Formula
  include Language::Python::Shebang

  desc "Local web pages around your PokeTokenBar save"
  homepage "https://github.com/DyRize/TokenDex"
  url "https://github.com/DyRize/TokenDex/releases/download/v0.1.0-alpha.1/tokendex-0.1.0-alpha.1.tar.gz"
  sha256 "9f6bef71e6f64965bf5015d53dee9df7602e37765af27be974113454bea95c94"
  license "MIT"

  depends_on :macos
  depends_on "python@3.14"

  def install
    libexec.install "serve.py", "dist"
    rewrite_shebang detected_python_shebang, libexec/"serve.py"
    chmod 0755, libexec/"serve.py"
    (bin/"tokendex").write_env_script libexec/"serve.py", "--open", {}
  end

  def caveats
    <<~EOS
      `tokendex` serves the pages on http://127.0.0.1:8649 and opens them. Ctrl+C stops it.
      To keep it running in the background until you stop it, without starting at login:
        brew services run tokendex
    EOS
  end

  service do
    run [opt_libexec/"serve.py"]
    keep_alive true
    log_path var/"log/tokendex.log"
    error_log_path var/"log/tokendex.log"
  end

  test do
    pid = spawn libexec/"serve.py"
    begin
      sleep 2
      assert_match "TokenDex", shell_output("curl -s http://127.0.0.1:8649/")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
