cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1389"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1389/agentshield_0.2.1389_darwin_amd64.tar.gz"
      sha256 "9fc44089ed63dc3f131e7602b67c3fd862eacacf140bbc0379c72efa488f4088"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1389/agentshield_0.2.1389_darwin_arm64.tar.gz"
      sha256 "4d22d9d5b5d253d01c6c123e06cc07157f1c1ca7c3c5ab9f9484fc69a25840ca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1389/agentshield_0.2.1389_linux_amd64.tar.gz"
      sha256 "c9f6d3d82d529d8321fe03dda6b3775bd966f2d4bd99205d2d62605f9eb68d21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1389/agentshield_0.2.1389_linux_arm64.tar.gz"
      sha256 "74dbb81ede5a92fc227522e451a34fb7d797c610eed9b751b18c1cc9d034dabe"
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
