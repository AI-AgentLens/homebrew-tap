cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1250"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1250/agentshield_0.2.1250_darwin_amd64.tar.gz"
      sha256 "3da51674ab5ad39f9555a4871497b3eaef183deffaee6e9e7b76b5e284fd8a9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1250/agentshield_0.2.1250_darwin_arm64.tar.gz"
      sha256 "803dae143a9db1011004f41d75f2c50e9e9d44f478059b0ee49e3a050c6f0365"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1250/agentshield_0.2.1250_linux_amd64.tar.gz"
      sha256 "6ce8ca5e8cba1e6d1c9b1b5877c94db72eea2e7c62ca22de92a64eeecb01859c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1250/agentshield_0.2.1250_linux_arm64.tar.gz"
      sha256 "74a15315cfd9b116bc7b24a56600a8d67d0a09ecc673f41cc638681cde6a836a"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
