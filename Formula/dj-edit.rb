class DjEdit < Formula
  desc "Auto-edit DJ-set videos into TikTok-ready cuts (9:16 + 16:9, beat-snapped, virtual-camera reframing)"
  homepage "https://github.com/Y0lan/dj-edit"
  url "https://github.com/Y0lan/dj-edit/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "86f8276c7183f1f4545f896756b21b69f0e25564da7d11d7d7bdb74939fd77c0"
  license "MIT"
  version "0.2.0"

  depends_on "ffmpeg"
  depends_on "python@3.11"
  depends_on "jq"

  def install
    # Install the dj-edit tree into share/dj-edit/
    share_root = share/"dj-edit"
    share_root.mkpath
    (share_root/"bin").install Dir["bin/*"]
    (share_root/"lib").install Dir["lib/*"]
    (share_root/"presets").install Dir["presets/*"] if Dir.exist?("presets")
    (share_root/"examples").install Dir["examples/*"] if Dir.exist?("examples")
    (share_root/"docs").install Dir["docs/*"] if Dir.exist?("docs")
    share_root.install "requirements.txt"
    share_root.install "pyproject.toml" if File.exist?("pyproject.toml")

    # Create a Python venv and install dependencies inside it
    venv_path = share_root/"venv"
    system Formula["python@3.11"].opt_libexec/"bin/python", "-m", "venv", venv_path
    system venv_path/"bin/pip", "install", "--quiet", "-r", share_root/"requirements.txt"

    # Symlink the launcher into bin/ on the user's PATH
    (bin/"dj-edit").write <<~LAUNCHER
      #!/usr/bin/env bash
      exec "#{share_root}/bin/dj-edit" "$@"
    LAUNCHER
    chmod 0755, bin/"dj-edit"

    # Install the .command wrapper into share (macOS only). Brew runs in a
    # sandbox and cannot write to /Applications directly — user copies it
    # there themselves (see caveats).
    if OS.mac? && File.exist?("dj-edit-mac.command")
      share_root.install "dj-edit-mac.command"
    end
  end

  def caveats
    msg = <<~EOS
      dj-edit is installed at:
        #{share}/dj-edit/

      Try the smoke test:
        dj-edit quickstart --demo

      Verify the install:
        dj-edit doctor
    EOS

    if OS.mac?
      msg += <<~EOS

        To get the double-clickable macOS launcher, copy it into /Applications:
          cp "#{share}/dj-edit/dj-edit-mac.command" /Applications/
          chmod +x /Applications/dj-edit-mac.command

        Then double-click /Applications/dj-edit-mac.command in Finder.
        First launch triggers Gatekeeper — right-click → Open → confirm once.
      EOS
    end

    msg
  end

  test do
    # Smoke test: doctor should exit 0 with all deps installed by brew
    system bin/"dj-edit", "doctor"
  end
end
