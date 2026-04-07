cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.467"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.467/agentshield_0.2.467_darwin_amd64.tar.gz"
      sha256 "5a961546beec9dcc7c2ddf3e8f48a6bd4979108e6c5be842e888b1c6fb329379"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.467/agentshield_0.2.467_darwin_arm64.tar.gz"
      sha256 "bdd37192b75ed4a649c0dacfefc9eecad58671a3f2c9c01fcf24f7e381c4f5c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.467/agentshield_0.2.467_linux_amd64.tar.gz"
      sha256 "383854cc384ba84e1f80191cb446797dff499d74f1d4261d66f8e7a8c4b1c9e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.467/agentshield_0.2.467_linux_arm64.tar.gz"
      sha256 "d45c1be7c6a82bddc911b3f877ccba60512f18a3e21f36d5549a16636c4890b9"
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
