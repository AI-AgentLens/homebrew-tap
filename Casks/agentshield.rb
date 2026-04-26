cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.753"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.753/agentshield_0.2.753_darwin_amd64.tar.gz"
      sha256 "1f57085332e45c193b62511078abf6815bdde2c5b7555b9ecc1b08f234fd72f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.753/agentshield_0.2.753_darwin_arm64.tar.gz"
      sha256 "4e37f27343697fe87824dfea9683891cc6b6a495e741a24c74ad4b94e0c6138e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.753/agentshield_0.2.753_linux_amd64.tar.gz"
      sha256 "8542a0e0dabc89f1cc6bff39bb5b15a72e0b03dce3e0f4c316cf9f87f896a551"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.753/agentshield_0.2.753_linux_arm64.tar.gz"
      sha256 "959b17b986fc6f1deda4f462160a91afcc557398dd20eaf9fb0ea58a7bc74325"
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
