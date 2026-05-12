class DjEdit < Formula
  desc "Auto-edit DJ-set videos into TikTok-ready cuts (9:16 + 16:9, beat-snapped, virtual-camera reframing)"
  homepage "https://github.com/Y0lan/dj-edit"
  url "https://github.com/Y0lan/dj-edit/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7682ce82b04f17326c1b2ebd597456aa2dfade3bf010c3fd0e062773ff85c067"
  license "MIT"
  version "0.1.0"

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

    # Install the .command wrapper into /Applications (macOS only)
    if OS.mac? && File.exist?("dj-edit-mac.command")
      share_root.install "dj-edit-mac.command"
      # Create a launcher in /Applications
      app_path = "/Applications/dj-edit-mac.command"
      ohai "Creating #{app_path}"
      # Use a small launcher script that defers to the installed copy
      File.write(app_path, <<~APPCMD)
        #!/usr/bin/env bash
        exec "#{share_root}/dj-edit-mac.command" "$@"
      APPCMD
      chmod 0755, app_path
    end
  end

  def caveats
    <<~EOS
      dj-edit is installed at:
        #{share}/dj-edit/

      Try the smoke test:
        dj-edit quickstart --demo

      macOS GUI launcher:
        open /Applications/dj-edit-mac.command

      First launch will trigger Gatekeeper. Right-click → Open to bypass once.

      See README + docs at:
        #{share}/dj-edit/README.md
    EOS
  end

  test do
    # Smoke test: doctor should exit 0 with all deps installed by brew
    system bin/"dj-edit", "doctor"
  end
end
